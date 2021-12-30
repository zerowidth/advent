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
    attr_accessor :neighbors # given a node, return neighboring nodes. required.

    # f(x) = g(x) + h(x), where g(x) is cost, h(x) is heuristic "expected remaining cost"
    attr_accessor :cost # lambda from node A to node B, returns cost value. required.
    # leave heuristic nil for dijkstra
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
    raise "must specify neighbors function" unless config.neighbors
  end

  def debug(msg = nil)
    puts(msg || yield) if config.debug
  end

  # find either a path from start to the goal, or from start to all leaf nodes
  def path(start:, goal: nil, leaf: nil, &goal_condition)
    raise "must specify goal, goal_condition, or leaf" if goal.nil? && leaf.nil? && goal_condition.nil?

    bar = TTY::ProgressBar.new("searching: :current iterations at :rate/sec in :elapsed", frequency: 10) unless config.debug

    frontier = PriorityQueue.new
    frontier << Node.new(start, 0, -config.heuristic[start, goal])
    came_from = {}
    cost_so_far = {}
    cost_so_far[start] = 0
    best = Float::INFINITY
    found = nil

    debug { "searching for best path from #{start} to #{goal || "first valid path"}" }
    iterations = 0
    until frontier.empty?
      iterations += 1
      bar.advance unless config.debug

      current_node = frontier.pop
      current = current_node.position
      debug { "current: #{current_node.position} (cost #{current_node.cost} priority #{current_node.priority}) cost so far #{cost_so_far[current]}".colorize(:blue) }
      # debug "  frontier:"
      # frontier.elements.each do |node|
      #   next unless node
      #   debug "    #{node.position} #{node.cost} #{node.priority}"
      # end

      config.each_step&.call start, current, came_from, cost_so_far

      if leaf && (current_node.cost > best)
        debug { "  skipping, cost #{current_node.cost} greater than best #{best}" }
        next
      end

      if ((goal && current == goal) || goal_condition&.call(current) || leaf&.call(current)) && cost_so_far[current] < best
        debug { "  => best so far, cost #{cost_so_far[current]}".colorize(:green) }
        puts "  => best so far, cost #{cost_so_far[current]}"
        best = cost_so_far[current]
        found = current
        break if goal || goal_condition # not really a goal if we're looking for all valid paths
      end

      break if config.break_if&.call(cost_so_far[current], best)

      neighbors = config.neighbors.call(current)
      debug { "  neighbors:\n  #{neighbors.map(&:to_s).join("\n  ")}" }
      neighbors.each do |neighbor|
        if came_from[current] == neighbor
          debug { "  #{neighbor} skipping, just came from it" }
          next
        end

        new_cost = cost_so_far[current] + config.cost.call(current, neighbor)
        # debug { "    #{neighbor}: new cost #{new_cost}, old #{cost_so_far[neighbor] || "nil"}" }
        next unless !cost_so_far.key?(neighbor) || new_cost < cost_so_far[neighbor]

        # debug { "    -> updating, #{neighbor} came from #{current}" }
        cost_so_far[neighbor] = new_cost
        # priority is negative, we want the smallest priority first
        priority = new_cost + config.heuristic[neighbor, goal]
        frontier << Node.new(neighbor, new_cost, -priority)
        came_from[neighbor] = current
      end
    end
    debug { "finished in #{iterations} iterations" }

    found && [reconstruct_path(start, found, came_from), cost_so_far[found]]
  ensure
    bar.finish unless config.debug
  end

  def reconstruct_path(start, current, came_from)
    # debug { "came_from: #{(came_from).pretty_inspect}" }
    # debug { "current: #{(current).inspect}" }
    path = []
    while current != start
      path << current
      current = came_from.fetch(current)
    end
    path.reverse
  end
end
