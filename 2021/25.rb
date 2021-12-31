require_relative "../toolkit"

class Grid
  attr_reader :width, :height, :grid

  def self.parse(rows, default: nil)
    width = rows.map(&:length).max
    height = rows.length
    grid = new(width, height, default: default)
    rows.each.with_index do |row, y|
      row.each.with_index do |value, x|
        grid[x, y] = value
      end
    end
    grid
  end

  def initialize(width, height, default: nil, grid: nil)
    @width = width
    @height = height
    @grid = grid || Array.new(width * height, default)
  end

  def dup
    self.class.new(width, height, grid: grid.dup)
  end

  include Enumerable
  def each
    0.upto(height - 1) do |y|
      0.upto(width - 1) do |x|
        yield [x, y, grid[(y * width) + x]]
      end
    end
  end

  def [](x, y)
    raise ArgumentError, "out of bounds" if x > width || y > height

    x = 0 if x == width
    y = 0 if y == height
    grid[x + (y * width)]
  end

  def []=(x, y, value)
    raise ArgumentError, "out of bounds" if x > width || y > height

    x = 0 if x == width
    y = 0 if y == height
    grid[x + (y * width)] = value
  end

  def draw
    0.upto(height - 1).map do |y|
      0.upto(width - 1).map do |x|
        self[x, y]
      end.join
    end.join("\n")
  end
end

def part1(input)
  grid = Grid.parse(input.lines_of(:chars), default: "?")

  debug { grid.draw }

  changed = true
  steps = 0
  bar = progress_bar(title: "moving cucumbers...") unless debug?
  while changed
    changed = false
    steps += 1
    bar.advance unless debug?
    next_grid = grid.dup
    grid.each do |x, y, v|
      if v == ">" && grid[x + 1, y] == "."
        changed = true
        next_grid[x, y] = "."
        next_grid[x + 1, y] = v
      end
    end
    grid = next_grid
    next_grid = next_grid.dup
    grid.each do |x, y, v|
      if v == "v" && grid[x, y + 1] == "."
        changed = true
        next_grid[x, y] = "."
        next_grid[x, y + 1] = v
      end
    end
    grid = next_grid
    debug { "--- step #{steps} ---" }
    debug { grid.draw }
  end
  bar.finish unless debug?

  steps
end

def part2(input)
  input.lines
end

ex1 = <<EX
v...>>.vv>
.vv>>.vv..
>>.>v>...v
>>v>>.>.v.
v>v.vv.v..
>.>>..v...
.vv..>.>v.
v.v..>>v.v
....v..v.>
EX

part 1
with :part1
debug!
try ex1, 58
no_debug!
try puzzle_input