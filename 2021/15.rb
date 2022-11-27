require_relative "../toolkit"
require_relative "../2019/simple_grid"
require_relative "../graph_search"

def parse(input)
  grid = SimpleGrid.new
  input.lines.each.with_index do |line, y|
    line.digits.each.with_index do |v, x|
      grid.set(x, y, v)
    end
  end
  grid
end

def part1(input)
  grid = parse(input)

  path = grid.path(
    [0, 0],
    goal: [grid.width, grid.height],
    diagonal: false,
    filter: ->(pos) { grid.at(*pos) },
    cost: ->(_from, to) { grid.at(*to) },
  )
  debug "path: #{path}"
  values = path.map { |x, y| grid.at(x, y) }
  debug "values: #{values}"
  values.sum
end

def part1_graphsearch(input)
  grid = parse(input)

  search = GraphSearch.new do |config|
    config.debug = debug?
    config.neighbors = lambda do |pos|
      grid.adjacent_points(*pos, diagonal: false).select { |p| grid.at(*p) }
    end
    config.cost = ->(_from, to) { grid.at(*to) }
    config.heuristic = ->(from, to) { SimpleGrid.taxicab(from, to) }
  end

  path = search.path(start: [0, 0], goal: [grid.width, grid.height])
  debug "path: #{path}"
  values = path.first.map { |x, y| grid.at(x, y) }
  debug "values: #{values}"
  values.sum
end

def expand(grid)
  new_grid = SimpleGrid.new
  w = grid.width
  h = grid.height
  0.upto(4) do |dy|
    0.upto(4) do |dx|
      0.upto(h) do |y|
        0.upto(w) do |x|
          value = grid.at(x, y) + dx + dy
          value = (value % 9) if value > 9
          new_grid.set(x + (dx * (w + 1)), y + (dy * (h + 1)), value)
        end
      end
    end
  end
  new_grid
end

def part2(input)
  grid = SimpleGrid.new
  input.lines.each.with_index do |line, y|
    line.digits.each.with_index do |v, x|
      grid.set(x, y, v)
    end
  end

  grid = expand(grid)
  debug "grid:\n#{grid}"

  path = grid.path(
    [0, 0],
    goal: [grid.width, grid.height],
    diagonal: false,
    filter: ->(pos) { grid.at(*pos) },
    cost: ->(_from, to) { grid.at(*to) }
  )
  debug "path: #{path}"
  values = path.map { |x, y| grid.at(x, y) }
  debug "values: #{values}"
  values.sum
end

def part2_graphsearch(input)
  grid = SimpleGrid.new
  input.lines.each.with_index do |line, y|
    line.digits.each.with_index do |v, x|
      grid.set(x, y, v)
    end
  end

  grid = expand(grid)
  debug "grid:\n#{grid}"

  search = GraphSearch.new do |config|
    config.debug = debug?
    config.neighbors = lambda do |pos|
      grid.adjacent_points(*pos, diagonal: false).select { |p| grid.at(*p) }
    end
    config.cost = ->(_from, to) { grid.at(*to) }
    config.heuristic = ->(from, to) { SimpleGrid.taxicab(from, to) }
  end

  path = search.path(start: [0, 0], goal: [grid.width, grid.height])
  debug "path: #{path}"
  values = path.first.map { |x, y| grid.at(x, y) }
  debug "values: #{values}"
  values.sum
end

ex1 = <<EX
1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581
EX

part 1
with :part1
debug!
try ex1, 40
with :part1_graphsearch
try ex1, 40
no_debug!
try puzzle_input

part 2
with :part2_graphsearch
# debug!
try ex1, 315
no_debug!
try puzzle_input
