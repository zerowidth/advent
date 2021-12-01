require_relative "../toolkit"

def part1(input)
  input.numbers.each_cons(2).count { |a, b| b - a > 0 }
end

def part2(input)
  windows = input.numbers.each_cons(3).map(&:sum)
  windows.each_cons(2).count { |a, b| b - a > 0 }
end

ex1 = <<-EX
199
200
208
210
200
207
240
269
260
263
EX

part 1
with :part1
debug!
try ex1, expect: 7
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, expect: 5
no_debug!
try puzzle_input
