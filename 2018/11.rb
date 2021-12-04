require_relative "../toolkit"

def part1(input)
  serial = input.numbers.first

  grid = Array.new(300 * 300) do |i|
    x = i % 300
    y = i / 300
    power_level x, y, serial
  end

  totals = powers_by_size(grid, 3)
  totals.max_by(&:last).first.map(&:to_s).join(",")
end

def powers_by_size(grid, size)
  totals = {}
  0.upto(300 - size) do |y|
    0.upto(300 - size) do |x|
      power = 0.upto(size - 1).flat_map do |dx|
        0.upto(size - 1).map do |dy|
          grid[(y + dy) * 300 + x + dx]
        end
      end
      totals[[x, y]] = power.sum
    end
  end

  totals
end

def power_level(x, y, serial)
  rack_id = x + 10
  power = rack_id * y
  power += serial
  power *= rack_id
  power = power % 1000 / 100
  power - 5
end

# https://en.wikipedia.org/wiki/Summed-area_table
class SummedAreaTable
  attr_reader :areas, :width, :height

  def initialize(grid, width, height)
    @areas = Array.new(width, height)
    @width = width
    @height = height

    areas[0] = grid[0]

    height.times_with_progress(title: "generating areas") do |y|
      width.times do |x|
        areas[x + (y * width)] =
          grid[x + (y * width)] +
          at(x - 1, y) +
          at(x, y - 1) -
          at(x - 1, y - 1)
      end
    end
  end

  def at(x, y)
    if x < 0 || x >= width || y < 0 || y > height
      0
    else
      areas[x + (y * width)]
    end
  end

  def sum(x, y, w, h)
    a = at(x - 1, y - 1)
    b = at(x - 1 + w, y - 1)
    c = at(x - 1, y - 1 + h)
    d = at(x - 1 + w, y - 1 + h)
    d - b - c + a
  end
end

def sat_test(input, x, y, w, h)
  sat = SummedAreaTable.new(input.numbers, 6, 6)
  sat.sum(x, y, w, h)
end

def part2(input)
  serial = input.numbers.first

  grid = Array.new(300 * 300) do |i|
    x = i % 300
    y = i / 300
    power_level x, y, serial
  end

  sat = SummedAreaTable.new(grid, 300, 300)

  bar = progress_bar(total: 300, title: "searching for best area")
  by_size = 1.upto(300).lazy.map do |size|
    best = 0.upto(300 - size).flat_map do |y|
      0.upto(300 - size).map do |x|
        [x, y, size, sat.sum(x, y, size, size)]
      end
    end.max_by(&:last)
    bar.advance
    best
  end
  max = by_size.each_cons(2) do |a, b|
    break a if b.last < a.last
  end
  bar.finish

  max.first(3).map(&:to_s).join(",")
end

ex1 = <<-EX
18
EX

sat_example = <<EX
31 2 4 33 5 36
12 26 9 10 29 25
13 17 21 22 20 18
24 23 15 16 14 19
30 8 28 27 11 7
1 35 34 3 32 6
EX

part 1
with :part1
debug!
try ex1, expect: "33,45"
no_debug!
try puzzle_input

part 2
debug!

with :sat_test
try sat_example, 0, 0, 1, 1, 31
try sat_example, 2, 3, 3, 2, 111

with :part2
try ex1, expect: "90,269,16"
no_debug!
try puzzle_input
