require_relative "../toolkit"
require_relative "./intcode"

def part1(input)
  cpu = Intcode.from_program(input)
  cpu.run

  grid = Grid.new
  view = cpu.output.map(&:chr).join("").split("\n")
  view.each.with_index do |line, y|
    line.each_char.with_index do |char, x|
      grid.set(x, y, char)
    end
  end

  # draw intersections
  grid.each do |x, y, v|
    if v == "#" && grid.adjacent_values(x, y, diagonal: false).all? { |a| a == "#" }
      grid.set(x,y, "O")
    end
  end
  puts grid.to_s(pad: 0)

  # # then count them
  grid.select { |x, y, v| v == "O" }.map do |x, y, v|
    x * y
  end.sum
end

def part2(input)

=begin
manual solution to the puzzle:

L,12,L,12,R,4,     A
R,10,R,6,R,4,R,4,  B
L,12,L,12,R,4,     A
R,6,L,12,L,12,     C
R,10,R,6,R,4,R,4,  B
L,12,L,12,R,4,     A
R,10,R,6,R,4,R,4,  B
R,6,L,12,L,12,     C
R,6,L,12,L,12,     C
R,10,R,6,R,4,R,4,  B
=end

  prog = "A,B,A,C,B,A,B,C,C,B"
  a = "L,12,L,12,R,4"
  b = "R,10,R,6,R,4,R,4"
  c = "R,6,L,12,L,12"
  draw = "n"

  cpu = Intcode.from_program(input)
  cpu[0] = 2
  [prog, a, b, c, draw, "\n"].join("\n").chars.map(&:ord).each { |i| cpu << i }
  cpu.run
  dust = cpu.output.pop
  # view = cpu.output.map(&:chr).join("").split("\n")
  # view.each { |l| puts l }
  dust
end

part 1
with :part1
try puzzle_input

part 2
with :part2
try puzzle_input
