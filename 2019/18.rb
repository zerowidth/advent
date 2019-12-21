require_relative "../toolkit"

def read(map)
  grid = Grid.new
  map.split("\n").each.with_index do |line, y|
    line.each_char.with_index do |char, x|
      grid.set x, y, char
    end
  end
  grid
end

class PathCost
  attr_reader :doors, :keys, :cost
  def initialize(doors, keys, cost)
    @doors = Set.new(doors)
    @keys = Set.new(keys)
    @cost = cost
  end
end

# This breadth-first search is basically held-karp, since it doesn't terminate
# when it finds a complete path, but keeps iterating to find the minimum.
def part1_optimized(input)
  grid = read input
  keys_to_collect = Set.new grid.select { |x, y, v| v =~ /[a-z]/ }.map(&:last)
  not_a_wall = ->(p) { v = grid.at(p[0], p[1]); v && v != "#" }

  puts "calculating node costs..."
  costs = {}
  (keys_to_collect.to_a + ["@"]).combination(2).each do |from, to|
    start = grid.locate(from).first
    goal = grid.locate(to).first
    path = grid.path(start, goal: goal, filter: not_a_wall, diagonal: false)

    doors = []
    keys = []
    path[0..-2].each do |x, y|
      value = grid.at(x, y)
      if value =~ /[a-z]/
        keys << value.downcase
      elsif value =~ /[A-Z]/
        doors << value.downcase
      end
    end

    pair = Set.new [from, to]
    costs[pair] = PathCost.new doors, keys, path.length
  end
  STDERR.puts "calcluated #{costs.length} pairs"

  edges = Hash.new { |h, k| h[k] = Set.new }
  costs.keys.each do |pair|
    a, b = *pair.to_a
    edges[a] << b
    edges[b] << a
  end

  frontier = []
  start = ["@", Set.new]
  frontier << start
  came_from = {}
  cost_so_far = {start => 0}
  best = Float::INFINITY
  found = nil

  iterations = 0
  until frontier.empty?
    iterations += 1
    print "#{iterations}\r" if iterations % 1000 == 0
    # frontier = frontier.sort_by(&:last)
    node_id = frontier.shift
    current, keys_held = node_id

    # STDERR.puts "current: #{current.inspect} holding #{keys_held}"
    if keys_held.length == keys_to_collect.length
      cost = cost_so_far[node_id]
      if cost < best
        found = node_id
        best = cost
      end
      next
    end

    edges[current].each do |neighbor|
      next if neighbor == "@"
      next if keys_held.include?(neighbor)
      pair = Set.new [current, neighbor]
      path_cost = costs[pair]
      # STDERR.puts "  -> checking #{neighbor}, requires #{path_cost.doors}"

      # find out if it's traversible: none of the remaining keys are required
      if !path_cost.doors.subset?(keys_held)
        # STDERR.puts "    => no path, don't have the right keys"
        next
      end

      new_cost = cost_so_far[node_id] + path_cost.cost
      neighbor_node = [neighbor, keys_held + [neighbor] + path_cost.keys]
      if !cost_so_far.key?(neighbor_node) || new_cost < cost_so_far[neighbor_node]
        cost_so_far[neighbor_node] = new_cost
        # STDERR.puts "    => searching #{neighbor}, adding #{path_cost.keys}"
        frontier << neighbor_node
        came_from[neighbor_node] = [current, keys_held]
      end
    end
  end
  puts "completed in #{iterations} iterations"

  # if we stopped after finding the goal:
  #
  # (this is unnecessary, we just need the best cost, but it's fine)
  if found
    # STDERR.puts "came_from: #{(came_from).pretty_inspect}" if $debug
    # STDERR.puts "current: #{(current).inspect}" if $debug
    current = found
    path = []
    while current != start
      path << current
      current = came_from.fetch(current)
    end
    path << start
    path.reverse.each_cons(2).map do |a, b|
      pair = Set.new([a.first,b.first])
      [b.first, costs[pair].cost]
    end.map(&:last).sum
  else
    nil
  end
end

def part2(input)
  grid = read input
  center = grid.detect do |x, y, v|
    v == "@" && grid.adjacent_values(x,y, diagonal: true).all? { |w| w == "." }
  end

  if center
    grid.set(center[0], center[1], "#")
    grid.adjacent_points(center[0], center[1]).each do |x, y|
      if x == center[0] || y == center[1]
        grid.set(x, y, "#")
      else
        grid.set(x, y, "@")
      end
    end
  end

  grid.locate("@").each.with_index do |p, i|
    grid.set(*p, i.to_s)
  end
  puts grid.to_s(pad: 0)

  keys_to_collect = Set.new grid.select { |x, y, v| v =~ /[a-z]/ }.map(&:last)
  not_a_wall = ->(p) { v = grid.at(p[0], p[1]); v && v != "#" }

  puts "calculating node costs..."
  costs = {}
  (keys_to_collect.to_a + %w(0 1 2 3)).combination(2).each do |from, to|
    start = grid.locate(from).first
    goal = grid.locate(to).first
    path = grid.path(start, goal: goal, filter: not_a_wall, diagonal: false)
    next unless path

    doors = []
    keys = []
    path[0..-2].each do |x, y|
      value = grid.at(x, y)
      if value =~ /[a-z]/
        keys << value.downcase
      elsif value =~ /[A-Z]/
        doors << value.downcase
      end
    end

    pair = Set.new [from, to]
    costs[pair] = PathCost.new doors, keys, path.length
  end
  STDERR.puts "calcluated #{costs.length} pairs"

  edges = Hash.new { |h, k| h[k] = Set.new }
  costs.keys.each do |pair|
    a, b = *pair.to_a
    edges[a] << b
    edges[b] << a
  end

  frontier = []
  start = [%w(0 1 2 3), Set.new]
  frontier << start
  came_from = {}
  cost_so_far = {start => 0}
  best = Float::INFINITY
  found = nil

  iterations = 0
  until frontier.empty?
    iterations += 1
    print "#{iterations}\r" if iterations % 1000 == 0
    node_id = frontier.shift
    current, keys_held = node_id

    # STDERR.puts "#{node_id}"
    if keys_held.length == keys_to_collect.length
      cost = cost_so_far[node_id]
      if cost < best
        STDERR.puts "found: #{node_id} cost #{cost}"
        best = cost
      end
      next
    end

    current.each.with_index do |from, fi|
      edges[from].each do |neighbor|
        next if neighbor =~ /\d/ # ignore entrances
        next if keys_held.include?(neighbor)
        pair = Set.new [from, neighbor]
        path_cost = costs[pair]
        next unless path_cost # no path exists
        # STDERR.puts "  -> checking #{neighbor}, requires #{path_cost.doors}"

        # find out if it's traversible: none of the remaining keys are required
        if !path_cost.doors.subset?(keys_held)
          # STDERR.puts "    => no path, don't have the right keys"
          next
        end

        new_cost = cost_so_far[node_id] + path_cost.cost
        neighbor_pos = current.dup
        neighbor_pos[fi] = neighbor
        neighbor_node = [neighbor_pos, keys_held + [neighbor] + path_cost.keys]
        if !cost_so_far.key?(neighbor_node) || new_cost < cost_so_far[neighbor_node]
          cost_so_far[neighbor_node] = new_cost
          # STDERR.puts "    => searching #{neighbor_pos}, adding #{path_cost.keys}"
          frontier << neighbor_node
          came_from[neighbor_node] = [from, keys_held]
        end
      end
    end
  end
  puts "completed in #{iterations} iterations"

  best
end

ex1 = <<-EX
#########
#b.A.@.a#
#########
EX

ex2 = <<-EX
########################
#f.D.E.e.C.b.A.@.a.B.c.#
######################.#
#d.....................#
########################
EX

ex3 = <<-EX
########################
#...............b.C.D.f#
#.######################
#.....@.a.B.c.d.A.e.F.g#
########################
EX

ex4 = <<-EX
#################
#i.G..c...e..H.p#
########.########
#j.A..b...f..D.o#
########@########
#k.E..a...g..B.n#
########.########
#l.F..d...h..C.m#
#################
EX
ex5 = <<-EX
########################
#@..............ac.GI.b#
###d#e#f################
###A#B#C################
###g#h#i################
########################
EX

ex6 = <<-EX
#######
#a.#Cd#
##...##
##.@.##
##...##
#cB#Ab#
#######
EX

ex7 = <<-EX
###############
#d.ABC.#.....a#
######@#@######
###############
######@#@######
#b.....#.....c#
###############
EX

ex8 = <<-EX
#############
#DcBa.#.GhKl#
#.###@#@#I###
#e#d#####j#k#
###C#@#@###J#
#fEbA.#.FgHi#
#############
EX

ex9 = <<-EX
#############
#g#f.D#..h#l#
#F###e#E###.#
#dCba...BcIJ#
#####.@.#####
#nK.L...G...#
#M###N#H###.#
#o#m..#i#jk.#
#############
EX

part 1
with :part1_optimized
try ex1, expect: 8
try ex2, expect: 86
try ex3, expect: 132
try ex4, expect: 136
try ex5, expect: 81
try puzzle_input

part 2
with :part2
try ex6, expect: 8
try ex7, expect: 24
try ex8, expect: 32
try ex9, expect: 72
try puzzle_input
