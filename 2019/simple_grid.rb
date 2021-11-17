# infinite grid, using "raw" x/y coords
class SimpleGrid

  # cost function
  def self.taxicab(from, to)
    from.map(&:abs).zip(to.map(&:abs)).map(&:sum).sum
  end

  def initialize(&value_block)
    @points = {}
    @value_block = value_block
  end

  def set(x,y, value)
    @points[ [x, y] ] = value
  end

  def at(x, y)
    k = [x, y]
    if @points.key? k
      @points[k]
    elsif @value_block
      @points[k] = @value_block.call(x, y)
    end
  end

  def at?(x, y)
    k = [x, y]
    @points.key? k
  end

  def locate(value=nil, &filter)
    points = filter ? select(&filter) : select { |x, y, v| v == value }
    points.map { |x, y, v| [x, y] }
  end

  def width
    xs = @points.keys.map(&:first)
    xs.max - xs.min
  end

  def height
    ys = @points.keys.map(&:last)
    ys.max - ys.min
  end

  def adjacent_points(cx, cy, diagonal: true)
    vs = []
    (cx-1).upto(cx+1) do |x|
      (cy-1).upto(cy+1) do |y|
        next if x == cx && y == cy
        next if !diagonal && x != cx && y != cy
        vs << [x,y]
      end
    end
    vs
  end

  def adjacent_values(cx, cy, diagonal: true)
    vs = []
    (cx-1).upto(cx+1) do |x|
      (cy-1).upto(cy+1) do |y|
        next if x == cx && y == cy
        next if !diagonal && x != cx && y != cy
        vs << at(x, y)
      end
    end
    vs
  end

  # dijkstra's, thanks https://www.redblobgames.com/pathfinding/a-star/introduction.html
  def path(start, goal: nil, filter:, diagonal: true, cost: self.class.method(:taxicab), &matcher)
    unless goal || block_given?
      raise ArgumentError, "missing target or target matcher block"
    end

    frontier = [] # list of [location, cost]
    frontier << [start, 0]
    came_from = {}
    cost_so_far = {}
    cost_so_far[start] = 0
    found = nil

    until frontier.empty?
      frontier = frontier.sort_by(&:last)
      current = frontier.shift[0]
      STDERR.puts "  current: #{(current).inspect}" if $debug
      if (matcher && matcher.call(current)) || (goal && current == goal)
        found = current
        STDERR.puts "  found! #{(current).inspect}" if $debug
        break
      end
      neighbors = adjacent_points(*current, diagonal: diagonal).select(&filter)
      STDERR.puts "  neighbors: #{(neighbors).inspect}" if $debug
      neighbors.each do |neighbor|
        new_cost = cost_so_far[current] + cost.call(current, neighbor)
        if !cost_so_far.key?(neighbor) || new_cost < cost_so_far[neighbor]
          cost_so_far[neighbor] = new_cost
          frontier << [neighbor, new_cost]
          came_from[neighbor] = current
        end
      end
    end

    # if we stopped after finding the goal:
    if found
      STDERR.puts "came_from: #{(came_from).pretty_inspect}" if $debug
      STDERR.puts "current: #{(current).inspect}" if $debug
      current = found
      path = []
      while current != start
        path << current
        current = came_from.fetch(current)
      end
      # path << start # leave current location off!
      path.reverse
    else
      nil
    end
  end

  include Enumerable
  def each(fill: false)
    keys = @points.keys
    xmin = keys.map(&:first).min
    xmax = keys.map(&:first).max
    ymin = keys.map(&:last).min
    ymax = keys.map(&:last).max
    ymin.upto(ymax) do |y|
      xmin.upto(xmax) do |x|
        v = fill ? at([x,y]) : @points[[x, y]]
        yield [x, y, v]
      end
    end
  end

  def points_set
    Set.new @points.keys
  end

  def to_s(pad: 1)
    s = ""
    keys = @points.keys
    xmin = keys.map(&:first).min
    xmax = keys.map(&:first).max
    ymin = keys.map(&:last).min
    ymax = keys.map(&:last).max

    size = @points.values.map(&:to_s).map(&:length).max + pad

    ymin.upto(ymax) do |y|
      xmin.upto(xmax) do |x|
        key = [x, y]
        v = @points[key]
        if v != nil
          s << v.to_s.rjust(size)
        else
          s << " " * size
        end
      end
      s << "\n"
    end
    s
  end
end
