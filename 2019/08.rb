require_relative "../toolkit"

def part1(input, width, height)
  input = input.strip.split("").map(&:to_i)
  layers = input.each_slice(width*height)
  fewest_zeros = layers.sort_by { |layer| layer.count(0) }.first
  fewest_zeros.count(1) * fewest_zeros.count(2)
end

def part2(input, width, height)
  input = input.strip.split("").map(&:to_i)
  layers = input.each_slice(width*height)
  combined = (width*height).times.map { |i| layers.detect { |layer| layer[i] != 2 }[i] }
  render combined.each_slice(width)
  combined.map(&:to_s).each_slice(width).map(&:join).join("\n")
end

def render(rows)
  rows.each do |row|
    row.each do |char|
      if char == 0
        print "  "
      else
        print "##"
      end
    end
    puts
  end
end

ex1 = <<-EX
EX

ex2 = <<-EX
EX

ex3 = <<-EX
EX

part 1
with :part1, 25, 6
try puzzle_input

part 2
with :part2, 2, 2
try "0222112222120000", "01\n10"

with :part2, 25, 6
try puzzle_input
