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
  numbers = input.each_line.map(&:strip).map(&:to_i)
  i = preamble
  loop do
    sums = numbers[i-preamble..i].combination(2).map(&:sum)
    return numbers[i] unless sums.include?(numbers[i])
    i +=1 
    break unless numbers[i]
  end
end

def part2(input, preamble:)
  numbers = input.each_line.map(&:strip).map(&:to_i)
  bad_sum = part1(input, preamble: preamble)

  2.upto(numbers.length) do |len|
    if found = numbers.each_cons(len).detect { |range| range.sum == bad_sum }
      return found.min + found.max
    end
  end
  nil
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
