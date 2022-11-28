require_relative "../toolkit"

def part1(input)
  input.lines.map(&:numbers).select do |sides|
    (sides[0] + sides[1]) > sides[2] &&
      (sides[1] + sides[2]) > sides[0] &&
      (sides[2] + sides[0]) > sides[1]
  end.length
end

def part2(input)
  input.lines.map(&:numbers).transpose.flatten.each_slice(3).select do |sides|
    (sides[0] + sides[1]) > sides[2] &&
      (sides[1] + sides[2]) > sides[0] &&
      (sides[2] + sides[0]) > sides[1]
  end.length
end

ex1 = <<EX
5 10 25
EX

ex2 = <<EX
101 301 501
102 302 502
103 303 503
201 401 601
202 402 602
203 403 603
EX

part 1
with :part1
debug!
try ex1, 0
# no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex2, 6
no_debug!
try puzzle_input
