require_relative "../toolkit"

ex1 = <<-EX
1721
979
366
299
675
1456
EX

def n_sum(input, n)
  input.each_line.map(&:to_i).combination(n).detect { |args| args.sum == 2020 }&.inject(1, &:*)
end

def part1(input)
  n_sum input, 2
end

def part2(input)
  n_sum input, 3
end

part 1
with :part1
try ex1, expect: 514579
try puzzle_input

part 2
with :part2
try ex1, expect: 241861950
try puzzle_input
