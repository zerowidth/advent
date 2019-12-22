class GraphSearch
  class Config
    attr_accessor :neighbors # given a node, return neighboring nodes
    attr_accessor :cost # lambda from node A to node B, returns cost value
    attr_accessor :break_if # lambda given current cost and best cost, for terminating a BFS
    attr_accessor :debug

    def initialize
      @debug = false
    end
  end

  attr_reader :config

  def initialize
    @config = Config.new
    yield @config
  end

  def debug(msg)
    if config.debug
      puts msg
    end
  end

  def path(start:, goal:)
    frontier = [] # list of [node, cost]
    frontier << [start, 0]
    came_from = {}
    cost_so_far = {}
    cost_so_far[start] = 0
    best = Float::INFINITY
    found = nil

    debug "searching for best path from #{start} to #{goal}"

    until frontier.empty?
      # frontier = frontier.sort_by(&:last) # only for dijkstra

      current = frontier.shift[0]
      debug "  current: #{current.inspect} cost so far #{cost_so_far[current]}"
      if current == goal && cost_so_far[current] < best
        debug "  best so far, cost #{cost_so_far[current]}"
        best = cost_so_far[current]
        found = current
      end

      if config.break_if
        break if config.break_if[cost_so_far[current], best]
      end

      neighbors = config.neighbors[current]
      debug "  neighbors: #{(neighbors).inspect}"
      neighbors.each do |neighbor|
        new_cost = cost_so_far[current] + config.cost[current, neighbor]
        debug "    #{neighbor} new cost #{new_cost}"
        if !cost_so_far.key?(neighbor) || new_cost < cost_so_far[neighbor]
          debug "    -> updating, #{neighbor} came from #{current}"
          cost_so_far[neighbor] = new_cost
          frontier << [neighbor, new_cost]
          came_from[neighbor] = current
        end
      end
    end

    # if we found the goal:
    if found
      debug "came_from: #{(came_from).pretty_inspect}"
      debug "current: #{(current).inspect}"
      current = found
      cost = 0
      path = []
      while current != start
        path << current
        current = came_from.fetch(current)
      end
      [path.reverse, cost_so_far[found]]
    else
      nil
    end
  end
end
