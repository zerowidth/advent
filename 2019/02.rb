require_relative "../toolkit"

def opcodes(input)
  opcodes = input.strip.split(",").map(&:to_i)
  interpret(opcodes.dup).map(&:to_s).join(",")
end

def opcodes_part1(input)
  opcodes = input.strip.split(",").map(&:to_i)
  opcodes[1] = 12
  opcodes[2] = 2
  interpret(opcodes.dup)[0]
end

def noun_verb(ops, noun, verb)
  ops[1] = noun
  ops[2] = verb
  interpret(ops)[0]
end

def part2(input)
  target = 19690720
  ops = puzzle_input.strip.split(",").map(&:to_i)
  found = catch(:done) do
    0.upto(99) do |noun|
      0.upto(99) do |verb|
        if noun_verb(ops.dup, noun, verb) == target
          throw :done, [noun, verb]
        end
      end
    end
  end
  found[0] * 100 + found[1]
end

def interpret(ops)
  pc = 0
  loop do
    case ops[pc]
    when 1
      a = ops[pc+1]
      b = ops[pc+2]
      out = ops[pc+3]
      ops[out] = ops[a] + ops[b]
      pc += 4
    when 2
      a = ops[pc+1]
      b = ops[pc+2]
      out = ops[pc+3]
      ops[out] = ops[a] * ops[b]
      pc += 4
    when 99
      break
    else
      raise "wtf: #{ops[pc]} at #{pc} in\n#{ops.inspect}"
    end
  end
  ops
end

part 1
with(:opcodes)
try "1,0,0,0,99", "2,0,0,0,99"
try "2,3,0,3,99", "2,3,0,6,99"
try "2,4,4,5,99,0", "2,4,4,5,99,9801"
try "1,1,1,4,99,5,6,0,99", "30,1,1,4,2,5,6,0,99"
with(:opcodes_part1)
try puzzle_input

part 2
with(:part2)
try puzzle_input
