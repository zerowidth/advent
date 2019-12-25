require_relative "../toolkit"
require_relative "./intcode"

ex1 = <<-EX
EX

ex2 = <<-EX
EX

ex3 = <<-EX
EX

PART1 = <<-PROG
NOT A T
NOT B J
OR T J -- not A, or not B
NOT C T
OR T J
AND D J
WALK
PROG

PART1V2 = <<-PROG
OR A T
AND B T
AND C T
NOT T T
OR T J
AND D J
WALK
PROG

PART2 = <<-PROG
OR A T
AND B T
AND C T
NOT T T
OR T J
AND D J
NOT E T
AND H T
OR E T
AND T J
RUN
PROG

=begin
....@............
#####.#.##.#.####
     ABCDEFGHI
(
=end

def go(input, asm)
  len = asm.split("\n").length
  raise ArgumentError, "too long: #{len}" if len > 15
  cpu = Intcode.from_program(input)
  cpu.run
  cpu.output.clear
  asm = asm.split("\n").map { |line| line.sub(/ --.*$/, "") }.join("\n") << "\n"
  asm.each_char.map { |char| cpu << char.ord }
  cpu.run
  puts cpu.output.take_while { |v| v <= 255 }.map(&:chr).join("")
  if cpu.output.last > 255
    cpu.output.last
  end
end

def part1(input, program)
  go input, program
end

def part2(input)
  go input, PART2
end

part 1
with :part1, PART1
try puzzle_input, expect: 19354437
with :part1, PART1V2
try puzzle_input, expect: 19354437

part 2
with :part2
try puzzle_input
