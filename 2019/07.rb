require_relative "../toolkit"

class Interpreter
  def initialize(memory, inputs=[])
    @memory = memory.dup
    @inputs = inputs
    @output = []
    @waiting = false
    @halted = false
    @ic = 0
  end

  def <<(value)
    @inputs << value
  end

  attr_reader :inputs
  attr_reader :output
  attr_reader :memory

  def run
    @waiting = false
    loop do
      opcode = memory[@ic] % 100
      arg1_immediate = memory[@ic] / 100 % 10 > 0
      arg2_immediate = memory[@ic] / 1000 % 10 > 0
      case opcode
      when 1
        a = arg1_immediate ? memory[@ic+1] : memory[memory[@ic+1]]
        b = arg2_immediate ? memory[@ic+2] : memory[memory[@ic+2]]
        out = memory[@ic+3]
        memory[out] = a + b
        @ic += 4
      when 2
        a = arg1_immediate ? memory[@ic+1] : memory[memory[@ic+1]]
        b = arg2_immediate ? memory[@ic+2] : memory[memory[@ic+2]]
        out = memory[@ic+3]
        memory[out] = a * b
        @ic += 4
      when 3
        input = @inputs.shift
        if !input
          @waiting = true
          break
        end
        a = memory[@ic+1]
        memory[a] = input
        @ic += 2
      when 4
        a = arg1_immediate ? memory[@ic+1] : memory[memory[@ic+1]]
        output << a
        @ic += 2
      when 5
        a = arg1_immediate ? memory[@ic+1] : memory[memory[@ic+1]]
        b = arg2_immediate ? memory[@ic+2] : memory[memory[@ic+2]]
        if a == 0
          @ic += 3
        else
          @ic = b
        end
      when 6
        a = arg1_immediate ? memory[@ic+1] : memory[memory[@ic+1]]
        b = arg2_immediate ? memory[@ic+2] : memory[memory[@ic+2]]
        if a == 0
          @ic = b
        else
          @ic += 3
        end
      when 7
        a = arg1_immediate ? memory[@ic+1] : memory[memory[@ic+1]]
        b = arg2_immediate ? memory[@ic+2] : memory[memory[@ic+2]]
        out = memory[@ic+3]
        memory[out] = a < b ? 1 : 0
        @ic += 4
      when 8
        a = arg1_immediate ? memory[@ic+1] : memory[memory[@ic+1]]
        b = arg2_immediate ? memory[@ic+2] : memory[memory[@ic+2]]
        out = memory[@ic+3]
        memory[out] = a == b ? 1 : 0
        @ic += 4
      when 99
        @halted = true
        break
      else
        raise "wtf?: #{opcode} at #{@ic} in\n#{memory.inspect}"
      end
    end
  end

  def waiting?
    @waiting
  end

  def halted?
    @halted
  end
end

def phase_sum(program, phases)
  phases.inject(0) do |input, phase|
    interpreter = Interpreter.new(program, [phase, input])
    interpreter.run
    interpreter.output.first
  end
end

def phase_sum_loop(program, phases)
  amps = phases.map { |phase| Interpreter.new(program, [phase]) }
  amps.first << 0
  until amps.all?(&:halted?)
    amps.each_with_index do |amp, i|
      # STDERR.puts "running amp #{i} with input #{amp.inputs}"
      amp.run
      # STDERR.puts "  -> halted #{amp.halted?} waiting #{amp.waiting?}"
      # STDERR.puts "  -> #{amp.output}"
      if amp.output.any?
        amps[ (i+1) % amps.length ] << amp.output.last
      end
    end
  end
  amps.last.output.last
end

def single_phase_sum(input, phases)
  program = input.gsub(/\s/,"").split(",").map(&:to_i)
  phase_sum program, phases
end

def phase_sum_max(input)
  program = input.gsub(/\s/,"").split(",").map(&:to_i)
  [0,1,2,3,4].permutation.map do |phases|
    [phases, phase_sum(program, phases)]
  end.max_by(&:last)
end

def single_phase_sum_loop(input, phases)
  program = input.gsub(/\s/,"").split(",").map(&:to_i)
  phase_sum_loop program, phases
end

def phase_sum_loop_max(input)
  program = input.gsub(/\s/,"").split(",").map(&:to_i)
  [5,6,7,8,9].permutation.map do |phases|
    [phases, phase_sum_loop(program, phases)]
  end.max_by(&:last)
end

ex1 = <<-EX
3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0
EX

ex2 = <<-EX
3,23,3,24,1002,24,10,24,1002,23,-1,23,
101,5,23,23,1,24,23,23,4,23,99,0,0
EX

ex3 = <<-EX
3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,
1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0
EX

part 1
with :single_phase_sum
try ex1, 43210, [4,3,2,1,0]
try ex2, 54321, [0,1,2,3,4]
try ex3, 65210, [1,0,4,3,2]
with :phase_sum_max
try puzzle_input

ex4 = <<-EX
3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,
27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5
EX

ex5 = <<-EX
3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,
-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,
53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10
EX

part 2
with :single_phase_sum_loop
try ex4, 139629729, [9,8,7,6,5]
try ex5, 18216, [9,7,8,5,6]
with :phase_sum_loop_max
try puzzle_input
