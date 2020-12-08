require_relative "../toolkit"

ex1 = <<-EX
nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6
EX

def parse(input)
  input.each_line.map(&:strip).map do |line|
    instr, value = *line.split(" ", 2)
    [instr, value.to_i]
  end
end

def interpret(instructions)
  acc = 0
  pc = 0
  executed = Set.new
  exited = false

  until executed.include?(pc) # prevent loops
    executed << pc

    if instructions[pc].nil? # reached the end!
      exited = true
      break
    end

    instr, value = *instructions[pc]
    case instr
    when "nop"
      pc += 1
    when "acc"
      acc += value
      pc += 1
    when "jmp"
      pc += value
    else
      raise "wtf #{pc} (#{instructions.length})"
    end
  end

  [acc, exited]
end

def part1(input)
  interpret(parse(input)).first
end

def part2(input)
  instructions = parse(input)
  instructions.each.with_index.select do |instr, i|
    instr.first != "acc"
  end.each do |instr, i|
    fixed = Marshal.load(Marshal.dump(instructions))
    if instr.first  == "jmp"
      fixed[i][0] = "nop"
    elsif instr.first == "nop"
      fixed[i][0] = "jmp"
    end

    acc, exited = interpret(fixed)
    return acc if exited
  end
end

part 1
with :part1
try ex1, expect: 5
try puzzle_input

part 2
with :part2
try ex1, expect: 8
try puzzle_input
