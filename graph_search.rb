require_relative "./priority_queue"

class GraphSearch

  class Node
    attr_reader :position, :cost, :priority

    def initialize(position, cost, priority)
      @position = position
      @cost = cost
      @priority = priority
    end

    include Comparable
    def <=>(other)
      priority <=> other.priority
    end
  end

  class Config
    attr_accessor :neighbors # given a node, return neighboring nodes

    # f(x) = g(x) + h(x), where g(x) is cost, h(x) is heuristic "expected remaining cost"
    attr_accessor :cost # lambda from node A to node B, returns cost value
    attr_accessor :heuristic # lambda from a node to a goal, returns estimated remaining cost

    attr_accessor :debug # set to true to enable per-step debugging
    attr_accessor :break_if # lambda given current cost, for terminating early
    attr_accessor :each_step # lambda given current path start, current, came_from, cost_so_far, for debugging

    def initialize
      @debug = false
      @cost = ->(_a, _b) { 1 }
      @heuristic = ->(_start, _goal) { 0 }
    end
  end

  attr_reader :config

  def initialize
    @config = Config.new
    yield @config
  end

  def debug(msg)
    puts msg if config.debug
  end

  def path(start:, goal: nil, &leaf)
    frontier = PriorityQueue.new
    frontier << Node.new(start, 0, -config.heuristic[start, goal])
    came_from = {}
    cost_so_far = {}
    cost_so_far[start] = 0
    best = Float::INFINITY
    found = nil

    debug "searching for best path from #{start} to #{goal || "first valid path"}"
    iterations = 0
    until frontier.empty?
      iterations += 1

      current_node = frontier.pop
      current = current_node.position
      debug "current: #{current_node.position} (cost #{current_node.cost}, priority #{current_node.priority}) cost so far #{cost_so_far[current]}"
      # debug "  frontier:"
      # frontier.elements.each do |node|
      #   next unless node
      #   debug "    #{node.position} #{node.cost} #{node.priority}"
      # end

      config.each_step&.call start, current, came_from, cost_so_far

      if ((goal && current == goal) || leaf.call(current)) && cost_so_far[current] < best
        debug "  => best so far, cost #{cost_so_far[current]}"
        best = cost_so_far[current]
        found = current
        break if goal # not really a goal if we're looking for all valid paths
      end

      break if config.break_if && config.break_if[cost_so_far[current], best]

      neighbors = config.neighbors[current]
      debug "  neighbors: #{neighbors.inspect}"
      neighbors.each do |neighbor|
        if came_from[current] == neighbor
          debug "  #{neighbor} skipping, just came from it"
          next
        end
        new_cost = cost_so_far[current] + config.cost[current, neighbor]
        debug "    #{neighbor}: new cost #{new_cost}, old #{cost_so_far[neighbor] || "nil"}"
        if !cost_so_far.key?(neighbor) || new_cost < cost_so_far[neighbor]
          debug "    -> updating, #{neighbor} came from #{current}"
          cost_so_far[neighbor] = new_cost
          # priority is negative, we want the smallest priority first
          priority = new_cost + config.heuristic[neighbor, goal]
          frontier << Node.new(neighbor, new_cost, -priority)
          came_from[neighbor] = current
        end
      end
    end
    debug "finished in #{iterations} iterations"

    return [reconstruct_path(start, found, came_from), cost_so_far[found]] if found
  end

  def reconstruct_path(start, current, came_from)
    # debug "came_from: #{(came_from).pretty_inspect}"
    # debug "current: #{(current).inspect}"
    path = []
    while current != start
      path << current
      current = came_from.fetch(current)
    end
    path.reverse
  end
end
