require_relative "../toolkit"

def part1(input)
  positions = input.numbers
  positions.min.upto(positions.max).map do |pos|
    score = positions.map { |p| (pos - p).abs }.sum
    [pos, score]
  end.min_by(&:last).last
end

def part2(input)
  positions = input.numbers
  positions.min.upto(positions.max).map do |pos|
    score = positions.map do |p|
       distance = (pos - p).abs
       1.upto(distance).sum
    end.sum
    [pos, score]
  end.min_by(&:last).last
end

ex1 = <<EX
16,1,2,0,4,2,7,1,2,14
EX

part 1
with :part1
debug!
try ex1, 37
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, expect: 168
no_debug!
try puzzle_input
