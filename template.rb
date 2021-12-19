require_relative "../toolkit"

def part1(input)
  input.lines
end

def part2(input)
  input.lines
end

ex1 = <<EX

EX

part 1
with :part1
debug!
try ex1, nil
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, nil
no_debug!
try puzzle_input
