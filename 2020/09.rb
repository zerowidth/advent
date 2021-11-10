require_relative "../toolkit"

ex1 = <<-EX
35
20
15
25
47
40
62
55
65
95
102
117
150
182
127
219
299
277
309
576
EX

def part1(input, preamble:)
  numbers = input.numbers
  _, i = numbers.each_cons(preamble).with_index.detect do |pre, i|
    !pre.combination(2).any? { |a, b| numbers[preamble + i] == a + b }
  end
  numbers[preamble + i]
end

def part2(input, preamble:)
  numbers = input.numbers
  bad_sum = part1(input, preamble: preamble)
  sequence = numbers.all_sequences(min_length: 2).detect { |range| range.sum == bad_sum }
  sequence.min + sequence.max
end

part 1
with :part1, preamble: 5
try ex1, expect: 127
with :part1, preamble: 25
try puzzle_input

part 2
with :part2, preamble: 5
try ex1, expect: 62
with :part2, preamble: 25
try puzzle_input
