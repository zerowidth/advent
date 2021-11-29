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

  # hash of: y => {length => [values]}
  rows = Hash.of { Hash.of { [] } }
  bar = progress_bar(title: "rows", total: 300)
  0.upto(299).each do |y|
    row = 0.upto(299).map { |x| grid[x + y * 300] }
    rows[y][1] = row
    2.upto(300) do |length|
      rows[y][length] = row.each_cons(length).map(&:sum)
    end
    bar.advance
  end
  bar.finish
  by_corner = {} # [x, y, length] => sum

  bar = progress_bar(total: 300, title: "areas")
  1.upto(300) do |size|
    0.upto(300 - size) do |y|
      0.upto(300 - size) do |x|
        value = 0.upto(size - 1).map do |row|
          rows.fetch(y + row).fetch(size)[x]
        end.sum
        by_corner[[x, y, size]] = value
      end
    end
    bar.advance
  end
  bar.finish

  best = by_corner.max_by(&:last)
  puts "best: #{best}"
  best.first.map(&:to_s).join(",")
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
debug!
try ex1, expect: "90,269,16"
no_debug!
try puzzle_input
