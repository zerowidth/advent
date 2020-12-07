require_relative "../toolkit"

ex1 = <<-EX
abc

a
b
c

ab
ac

a
a
a
a

b
EX

def part1(input)
  input.split("\n\n").map do |group|
    group.gsub(/\s/, "").split("").sort.uniq
  end.map(&:size).sum
end

def part2(input)
  input.split("\n\n").map do |group|
    answers = group.split("\n").map { |person| person.split("") }
    answers.reduce(Set.new(answers.first), &:&)
  end.map(&:size).sum
end

part 1
with :part1
try ex1, expect: 11
try puzzle_input

part 2
with :part2
try ex1, expect: 6
try puzzle_input
