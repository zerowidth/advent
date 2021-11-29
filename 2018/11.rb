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

def part2(input)
  serial = input.numbers.first

  grid = Array.new(300 * 300) do |i|
    x = i % 300
    y = i / 300
    power_level x, y, serial
  end

  by_size = {}
  1.upto(300).with_progress.each do |size|
    totals = powers_by_size(grid, size)
    by_size[size] = totals.max_by(&:last)
  end

  by_size
end

ex1 = <<-EX
18
EX

part 1
with :part1
debug!
try ex1, expect: "33,45"
no_debug!
try puzzle_input

part 2
with :part2
# debug!
try ex1, expect: "90,269,16"
no_debug!
try puzzle_input
