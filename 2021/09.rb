require_relative "../toolkit"

class Grid
  attr_reader :values, :width, :height

  def initialize(values, width)
    @values = values
    @width = width
    @height = values.length / width
  end

  include Enumerable

  def each
    0.upto(height - 1) do |y|
      0.upto(width - 1) do |x|
        yield [x, y]
      end
    end
  end

  def get(x, y)
    return nil if y < 0 || y >= height || x < 0 || x >= width

    values[x + (y * width)]
  end

  def neighbors(x, y)
    [
      [x + 1, y],
      [x - 1, y],
      [x, y + 1],
      [x, y - 1],
    ].select do |nx, ny|
      nx >= 0 && nx < width && ny >= 0 && ny < height
    end
  end

  def neighbor_values(x, y)
    neighbors(x, y).map { |nx, ny| get(nx, ny) }
  end
end

def part1(input)
  grid = Grid.new(input.digits, input.lines.first.digits.length)
  low_points = grid.select do |x, y|
    value = grid.get(x, y)
    grid.neighbor_values(x, y).all? { |nv| nv > value }
  end
  low_points.map { |x, y| grid.get(x, y) + 1 }.sum
end

def part2(input)
  grid = Grid.new(input.digits, input.lines.first.digits.length)

  low_points = grid.select do |x, y|
    value = grid.get(x, y)
    grid.neighbor_values(x, y).all? { |nv| nv > value }
  end

  low_points.map do |basin|
    seen = Set.new
    queue = []
    queue << basin
    while (pos = queue.pop)
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
