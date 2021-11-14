require_relative "../toolkit"

class CPU
  attr_reader :a, :b

  def initialize(instructions, a: 0, b: 0)
    @a = a
    @b = b
    interpret(instructions)
  end

  def interpret(instructions)
    pc = 0
    while pc < instructions.length
      i = instructions[pc]
      debug "#{i} | pc #{pc} a #{a} b #{b}"

      case i
      when /hlf (\w)/
        set($1) { |value| value / 2 }
        debug "  #{$1} now #{get($1)}"
      when /tpl (\w)/
        set($1) { |value| value * 3 }
        debug "  #{$1} now #{get($1)}"
      when /inc (\w)/
        set($1) { |value| value + 1 }
        debug "  #{$1} now #{get($1)}"
      when /jmp ([+-]\d+)/
        pc += $1.to_i
        next
      when /jie (\w), ([+-]\d+)/
        if get($1).even?
          pc += $2.to_i
          next
        end
      when /jio (\w), ([+-]\d+)/
        if get($1) == 1
          pc += $2.to_i
          next
        end
      else
        raise "unknown instruction #{i}"
      end

      pc += 1
    end
  end

  def get(reg)
    case reg
    when "a"
      @a
    when "b"
      @b
    else
      raise "unknown register #{reg}"
    end
  end

  def set(reg)
    case reg
    when "a"
      @a = yield @a
    when "b"
      @b = yield @b
    else
      raise "unknown register #{reg}"
    end
  end
end

ex1 = <<-EX
inc a
jio a, +2
tpl a
inc a
EX

def part1(input)
  instructions = input.each_line.map(&:strip)
  yield CPU.new(instructions)
end

def part2(input)
  instructions = input.each_line.map(&:strip)
  yield CPU.new(instructions, a: 1)
end

part 1
with :part1, &:a
debug!
try ex1, expect: 2
no_debug!
with :part1, &:b
try puzzle_input

part 2
with :part2, &:b
try puzzle_input
