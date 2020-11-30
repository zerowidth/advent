require_relative "../toolkit"

ex1 = <<-EX1
20
15
10
5
5
EX1

def part1(input, goal)
  containers = input.split("\n").map(&:to_i)
  1.upto(containers.length).flat_map do |n|
    containers.combination(n).select { |cs| cs.sum == goal }
  end.length
end

def part2(input, goal)
  containers = input.split("\n").map(&:to_i)
  combinations = 1.upto(containers.length).flat_map do |n|
    containers.combination(n).select { |cs| cs.sum == goal }
  end
  shortest = combinations.map(&:length).min
  combinations.select  { |c| c.length == shortest }.length
end

part 1
with :part1, 25
try ex1, expect: 4

with :part1, 150
try puzzle_input

part 2
with :part2, 25
try ex1, expect: 3

with :part2, 150
try puzzle_input