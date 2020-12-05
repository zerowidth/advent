require_relative "../toolkit"

ex1 = <<-EX
FBFBBFFRLR
EX

ex2 = "BFFFBBFRRR"
ex3 = "FFFBBBFRRR"
ex4 = "BBFFBBFRLL"

def part1(input)
  input.each_line.map(&:strip).map do |line|
    line.gsub(/./, "B" => 1, "F" => 0, "R" => 1, "L" => 0).to_i(2)
  end.sort.last
end

def part2(input)
  input.each_line.map(&:strip).map do |line|
    line.gsub(/./, "B" => 1, "F" => 0, "R" => 1, "L" => 0).to_i(2)
  end.sort.each_cons(2).detect { |a, b| b - a > 1 }.first + 1
end

part 1
with :part1
try ex1, expect: 357
try ex2, expect: 567
try ex3, expect: 119
try ex4, expect: 820
try puzzle_input

part 2
with :part2
try puzzle_input
