require_relative "../toolkit"

def part1(instructions, input=nil)
  memory = instructions.strip.split(",").map(&:to_i)
  interpret(memory.dup, input)
end

def interpret(memory, input=nil)
  ic = 0
  output = []
  loop do
    opcode = memory[ic] % 100
    arg1_immediate = memory[ic] / 100 % 10 > 0
    arg2_immediate = memory[ic] / 1000 % 10 > 0
    # arg3_immediate = memory[ic] / 10000 % 10 > 0
    case opcode
    when 1
      a = arg1_immediate ? memory[ic+1] : memory[memory[ic+1]]
      b = arg2_immediate ? memory[ic+2] : memory[memory[ic+2]]
      out = memory[ic+3]
      memory[out] = a + b
      ic += 4
    when 2
      a = arg1_immediate ? memory[ic+1] : memory[memory[ic+1]]
      b = arg2_immediate ? memory[ic+2] : memory[memory[ic+2]]
      out = memory[ic+3]
      memory[out] = a * b
      ic += 4
    when 3
      raise "no input, but input requested" unless input
      a = memory[ic+1]
      memory[a] = input
      ic += 2
    when 4
      a = arg1_immediate ? memory[ic+1] : memory[memory[ic+1]]
      output << a
      ic += 2
    when 5
      a = arg1_immediate ? memory[ic+1] : memory[memory[ic+1]]
      b = arg2_immediate ? memory[ic+2] : memory[memory[ic+2]]
      if a == 0
        ic += 3
      else
        ic = b
      end
    when 6
      a = arg1_immediate ? memory[ic+1] : memory[memory[ic+1]]
      b = arg2_immediate ? memory[ic+2] : memory[memory[ic+2]]
      if a == 0
        ic = b
      else
        ic += 3
      end
    when 7
      a = arg1_immediate ? memory[ic+1] : memory[memory[ic+1]]
      b = arg2_immediate ? memory[ic+2] : memory[memory[ic+2]]
      out = memory[ic+3]
      memory[out] = a < b ? 1 : 0
      ic += 4
    when 8
      a = arg1_immediate ? memory[ic+1] : memory[memory[ic+1]]
      b = arg2_immediate ? memory[ic+2] : memory[memory[ic+2]]
      out = memory[ic+3]
      memory[out] = a == b ? 1 : 0
      ic += 4
    when 99
      break
    else
      raise "wtf?: #{opcode} at #{ic} in\n#{memory.inspect}"
    end
  end
  {
    output: output,
    memory: memory,
  }
end

part 1
with :part1, 1
try "3,0,4,0,99", 1 do |out|
  puts "memory: #{out[:memory].inspect}"
  out[:output].first
end

try "1002,4,3,4,33", 99 do |out|
  puts "memory: #{out[:memory].inspect}"
  out[:memory][4]
end
try "102,3,4,4,33", 99 do |out|
  puts "memory: #{out[:memory].inspect}"
  out[:memory][4]
end
try puzzle_input do |out|
  out[:output]
end

part 2
first_output = ->(out) { out[:output].first }

# equal to 8
with :part1, 8
try "3,9,8,9,10,9,4,9,99,-1,8", 1, &first_output
try "3,3,1108,-1,8,3,4,3,99", 1, &first_output
with :part1, 7
try "3,9,8,9,10,9,4,9,99,-1,8", 0, &first_output
try "3,3,1108,-1,8,3,4,3,99", 0, &first_output

# less than 8
with :part1, 7
try "3,9,7,9,10,9,4,9,99,-1,8", 1, &first_output
try "3,3,1107,-1,8,3,4,3,99", 1, &first_output
with :part1, 9
try "3,9,7,9,10,9,4,9,99,-1,8", 0, &first_output
try "3,3,1107,-1,8,3,4,3,99", 0, &first_output

# jump test, 0 if input is 0, 1 if nonzero
with :part1, 0
try "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9", 0, &first_output
try "3,3,1105,-1,9,1101,0,0,12,4,12,99,1", 0, &first_output
with :part1, 1
try "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9", 1, &first_output
try "3,3,1105,-1,9,1101,0,0,12,4,12,99,1", 1, &first_output
with :part1, -1
try "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9", 1, &first_output
try "3,3,1105,-1,9,1101,0,0,12,4,12,99,1", 1, &first_output

with :part1, 5
try puzzle_input do |out|
  out[:output]
end
