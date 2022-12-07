require_relative "../toolkit"

SCORES = ("a".."z").to_a + ("A".."Z").to_a

def score(char)
  SCORES.index(char) + 1
end

def part1(input)
  input.lines.map do |line|
    len = line.length
    score((line.chars.first(len/2) & line.chars.last(len/2)).first)
  end.sum
end

def part2(input)
  input.lines.each_slice(3).map do |group|
    score(group.map(&:chars).reduce(:&).first)
  end.sum
end

ex1 = <<EX
vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw
EX

part 1
with :part1
debug!
try ex1, 157
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, 70
no_debug!
try puzzle_input
