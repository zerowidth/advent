require_relative "../toolkit"

def part1(input)
  pos = depth = 0
  input.lines.each do |line|
    num = line.number
    case line
    when /forward/
      pos += num
    when /up/
      depth -= num
    when /down/
      depth += num
    end
  end

  depth * pos
end

def part2(input)
  pos = depth = aim = 0
  input.lines.each do |line|
    num = line.number
    case line
    when /forward/
      pos += num
      depth += aim * num
    when /up/
      aim -= num
    when /down/
      aim += num
    end
  end

  depth * pos
end

ex1 = <<EX
forward 5
down 5
forward 8
up 3
down 8
forward 2
EX

part 1
with :part1
debug!
try ex1, expect: 150
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, expect: 900
no_debug!
try puzzle_input
