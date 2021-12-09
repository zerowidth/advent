require_relative "../toolkit"

class Grid
  attr_reader :width, :height

  def initialize(values, width, height)
    @values = values
    @width = width
    @height = height
    raise "no? #{@values.length}" unless @values.length == @width * @height
  end

  def low_points
    indices = @values.length.times.select do |i|
      x = i % @width
      y = i / @width
      v = get(x, y)
      low = [
        get(x + 1, y),
        get(x - 1, y),
        get(x, y + 1),
        get(x, y - 1),
      ].compact.all? { |w| w > v }
    end

    indices.map { |i| [i % width, i / width] }
  end

  def neighbors(x, y)
    [
        [x + 1, y],
        [x - 1, y],
        [x, y + 1],
        [x, y - 1],
    ].select { |x, y| ok?(x, y) }
  end

  def ok?(x, y)
    (0...width).include?(x) && (0...height).include?(y)
  end

  def get(x, y)
    return nil if y < 0 || y >= @height || x < 0 || x >= @width
    @values[x + (y * @width)]
  end
end

def part1(input)
  g = Grid.new(input.digits, input.lines.first.digits.length, input.lines.length)
  g.low_points.map { |x, y| g.get(x, y) + 1 }.sum
end

def part2(input)
  grid = Grid.new(input.digits, input.lines.first.digits.length, input.lines.length)
  basins = grid.low_points

  basins.map do |basin|
    seen = Set.new
    queue = []
    queue << basin

    while pos = queue.pop
      seen << pos
      grid.neighbors(*pos).each do |n|
        queue << n unless seen.include?(n) || grid.get(*n) == 9
      end
    end

    seen.size
  end.sort.last(3).reduce(&:*)
end

ex1 = <<EX
2199943210
3987894921
9856789892
8767896789
9899965678
EX

part 1
with :part1
debug!
try ex1, 15
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, 1134
no_debug!
try puzzle_input
