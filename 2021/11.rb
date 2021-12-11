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

  def set(x, y, value)
    raise "out of range: #{x} #{y}" if y < 0 || y >= height || x < 0 || x >= width

    values[x + (y * width)] = value
  end

  def to_s
    values.each_slice(width).map do |line|
      line.join(" ")
    end.join("\n")
  end

  def neighbors(x, y)
    [
      [x + 1, y],
      [x - 1, y],
      [x, y + 1],
      [x, y - 1],
      [x + 1, y + 1],
      [x - 1, y + 1],
      [x + 1, y - 1],
      [x - 1, y - 1],
    ].select do |nx, ny|
      nx >= 0 && nx < width && ny >= 0 && ny < height
    end
  end

  def neighbor_values(x, y)
    neighbors(x, y).map { |nx, ny| get(nx, ny) }
  end
end

def part1(input, iterations:)
  grid = Grid.new(input.digits, input.lines.first.digits.length)

  flashes = 0
  iterations.times_with_progress do |n|
    debug "iteration #{n}:"
    debug grid
    debug

    next_grid = Grid.new(Array.new(grid.width * grid.width, 0), grid.width)
    grid.each do |x, y|
      next_grid.set(x, y, grid.get(x, y) + 1)
    end
    grid = next_grid

    changed = false
    flashed = Set.new
    loop do
      changed = false
      grid.each do |x, y|
        next if flashed.include?([x, y]) || grid.get(x, y) <= 9

        flashed << [x, y]
        flashes += 1
        changed = true
        grid.neighbors(x, y).each do |nx, ny|
          grid.set(nx, ny, grid.get(nx, ny) + 1)
        end
      end
      break unless changed
    end

    flashed.each do |fx, fy|
      grid.set(fx, fy, 0)
    end
  end

  puts grid

  flashes
end

def part2(input)
  grid = Grid.new(input.digits, input.lines.first.digits.length)

  iteration = 0
  loop do
    iteration += 1
    debug "iteration #{iteration}:"
    debug grid
    debug

    next_grid = Grid.new(Array.new(grid.width * grid.width, 0), grid.width)
    grid.each do |x, y|
      next_grid.set(x, y, grid.get(x, y) + 1)
    end
    grid = next_grid

    changed = false
    flashed = Set.new
    loop do
      changed = false
      grid.each do |x, y|
        next if flashed.include?([x, y]) || grid.get(x, y) <= 9

        flashed << [x, y]
        changed = true
        grid.neighbors(x, y).each do |nx, ny|
          grid.set(nx, ny, grid.get(nx, ny) + 1)
        end
      end
      break unless changed
    end

    flashed.each do |fx, fy|
      grid.set(fx, fy, 0)
    end

    break if grid.values.all?(&:zero?)
  end

  iteration
end

ex1 = <<EX
5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526
EX

ex2 = <<EX
11111
19991
19191
19991
11111
EX

part 1
debug!
with :part1, iterations: 2
try ex2, 9
with :part1, iterations: 10
try ex1, 204
no_debug!
with :part1, iterations: 100
try ex1, 1656
try puzzle_input

part 2
with :part2
# debug!
try ex1, 195
no_debug!
try puzzle_input
