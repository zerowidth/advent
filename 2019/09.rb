require_relative "../toolkit"

class Interpreter
  def initialize(memory, inputs=[])
    @memory = memory.dup
    @inputs = inputs.dup
    @output = []
    @waiting = false
    @halted = false
    @ic = 0
    @relative = 0
  end

  def <<(value)
    @inputs << value
  end

  attr_reader :inputs
  attr_reader :output
  attr_reader :memory
  attr_writer :debug

  def debug(msg)
    puts msg if @debug
  end

  def run
    @waiting = false
    loop do
      opcode = get(@ic) % 100
      arg1_mode = get(@ic) / 100 % 10
      arg2_mode = get(@ic) / 1000 % 10
      arg3_mode = get(@ic) / 10000 % 10
      case opcode
      when 1
        debug "#{@ic} #{memory.slice(@ic, 4).inspect}"
        a = value_at(@ic + 1, arg1_mode)
        b = value_at(@ic + 2, arg2_mode)
        c = address_from @ic+3, arg3_mode
        debug "-> ADD #{a} #{b} -> ##{c}"
        set c, a + b
        @ic += 4
      when 2
        debug "#{@ic} #{memory.slice(@ic, 4).inspect}"
        a = value_at(@ic + 1, arg1_mode)
        b = value_at(@ic + 2, arg2_mode)
        c = address_from @ic+3, arg3_mode
        debug "-> MUL #{a} #{b} -> ##{c}"
        set c, a * b
        @ic += 4
      when 3
        debug "#{@ic} #{memory.slice(@ic, 2).inspect}"
        a = address_from(@ic+1, arg1_mode)
        debug "-> IN ##{a}"
        input = @inputs.shift
        if !input
          @waiting = true
          debug "  no input, waiting"
          break
        end
        debug "  set: #{input}"
        set a, input
        @ic += 2
      when 4
        debug "#{@ic} #{memory.slice(@ic, 2).inspect}"
        a = value_at(@ic + 1, arg1_mode)
        debug "-> OUT #{a}"
        output << a
        @ic += 2
      when 5
        debug "#{@ic} #{memory.slice(@ic, 3).inspect}"
        a = value_at(@ic + 1, arg1_mode)
        b = value_at(@ic + 2, arg2_mode)
        debug "-> JNZERO #{a} to #{b}"
        if a == 0
          @ic += 3
        else
          @ic = b
        end
      when 6
        debug "#{@ic} #{memory.slice(@ic, 3).inspect}"
        a = value_at(@ic + 1, arg1_mode)
        b = value_at(@ic + 2, arg2_mode)
        debug "-> JZERO #{a} to #{b}"
        if a == 0
          @ic = b
        else
          @ic += 3
        end
      when 7
        debug "#{@ic} #{memory.slice(@ic, 4).inspect}"
        a = value_at(@ic + 1, arg1_mode)
        b = value_at(@ic + 2, arg2_mode)
        c = address_from(@ic+3, arg3_mode)
        debug "-> LT #{a} #{b} -> ##{c}"
        set c, a < b ? 1 : 0
        @ic += 4
      when 8
        debug "#{@ic} #{memory.slice(@ic, 4).inspect}"
        a = value_at(@ic + 1, arg1_mode)
        b = value_at(@ic + 2, arg2_mode)
        c = address_from(@ic+3, arg3_mode)
        debug "-> EQ #{a} #{b} -> ##{c}"
        set c, a == b ? 1 : 0
        @ic += 4
      when 9
        debug "#{@ic} #{memory.slice(@ic, 2).inspect}"
        a = value_at(@ic + 1, arg1_mode)
        debug "-> REL #{a} from #{@relative}"
        @relative += a
        @ic += 2
      when 99
        debug "#{@ic} #{memory.slice(@ic, 1).inspect}"
        debug "-> HALT"
        @halted = true
        break
      else
        raise "wtf?: #{opcode} at #{@ic} in\n#{memory.inspect}"
      end
    end
  end

  def get(addr)
    memory.fetch addr, 0
  end

  def set(addr, value)
    memory[addr] = value
  end

  def address_from(address, mode)
    case mode
    when 0 # position
      get(address)
    when 1 # immediate
      raise "cannot use immediate mode for address!"
    when 2 # relative
      get(address) + @relative
    else
      raise "wtf? mode #{mode} address #{address}"
    end
  end

  def value_at(address, mode)
    case mode
    when 0 # position
      get get(address)
    when 1 # immediate
      get address
    when 2 # relative
      get(get(address) + @relative)
    else
      raise "wtf? mode #{mode} address #{address}"
    end
  end

  def waiting?
    @waiting
  end

  def halted?
    @halted
  end
end

def interpret(program, inputs = [], debug = false)
  memory = program.split(",").map(&:to_i)
  cpu = Interpreter.new(memory, inputs)
  cpu.debug = debug
  cpu.run
  cpu
end

quine = "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99"

part 1
with :interpret, [], true
try(quine, quine) { |cpu| cpu.output.map(&:to_s).join(",") }
with :interpret, [1], false
try(puzzle_input) { |cpu| cpu.output }

part 2
with :interpret, [2], false
try(puzzle_input) { |cpu| cpu.output }
