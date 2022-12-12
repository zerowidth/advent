require_relative "../toolkit"
require_relative "../2019/simple_grid"
require_relative "../graph_search"

def parse(input)
  grid = SimpleGrid.new
  input.lines.each.with_index do |line, y|
    line.chars.each.with_index do |v, x|
      grid.set(x, y, v)
    end
  end
  grid
end

def search(grid)
  GraphSearch.new do |config|
    config.debug = debug?
    config.neighbors = lambda do |(x, y)|
      current = grid.at(x, y)
      current = "a" if current == "S"
      grid.adjacent_points(x, y, diagonal: false).select do |cx, cy|
        value = grid.at(cx, cy)
        next unless value

        value = "z" if value == "E"
        value = "a" if value == "S"

        value.ord - current.ord <= 1
      end
    end
  end
end

def part1(input)
  grid = parse(input)

  search(grid).path(
    start: grid.locate("S").first,
    goal: grid.locate("E").first
  ).tap do |path|
    debug "path: #{path.inspect}"
  end&.first&.length
end

def part2(input)
  grid = parse(input)

  s = search(grid)
  e = grid.locate("E").first
  paths = grid.locate("S").concat(grid.locate("a")).map do |start|
    path = s.path(start: start, goal: e)
    if path
      debug "start at #{grid.at(*start)}: #{path.first.length}"
    end
    path
  end

  paths.compact.map(&:first).map(&:length).sort.first
end

ex1 = <<EX
Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
EX

part 1
with :part1
debug!
try ex1, 31
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, 29
no_debug!
try puzzle_input
