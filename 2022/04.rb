require_relative "../toolkit"

def range_pairs(input)
  input.lines.map do |line|
    line.split(",").map do |range|
      Range.new(*range.split("-").map(&:to_i))
    end
  end
end

def part1(input)
  range_pairs(input).count { |a, b| a.cover?(b) || b.cover?(a) }
end

def part2(input)
  range_pairs(input).count { |pair| !pair.map(&:to_a).reduce(:&).empty? }
end

ex1 = <<EX
2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8
EX

part 1
with :part1
debug!
try ex1, 2
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, 4
no_debug!
try puzzle_input
