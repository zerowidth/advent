require_relative "../toolkit"

def part1(input)
  input.sections.map(&:numbers).map(&:sum).max
end

def part2(input)
  input.sections.map(&:numbers).map(&:sum).sort.last(3).sum
end

ex1 = <<EX
1000
2000
3000

4000

5000
6000

7000
8000
9000

10000
EX

part 1
with :part1
debug!
try ex1, 24000
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, 45000
no_debug!
try puzzle_input
