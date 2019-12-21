require_relative "../toolkit"

def solution(input)
  prog = input.lines.map do |line|
    op, reg, operand = line.strip.split(" ", 3)
    [
      op,
      reg,
      operand =~ /\d+/ ? operand.to_i : operand
    ]
  end

  regs = Hash.new(0)
  pc = 0
  last = 0
  mul_count = 0

  while pc >= 0 && pc < prog.length
    # puts "#{pc} : #{prog[pc].inspect}"
    op, reg, arg = *prog[pc]
    if arg && arg.kind_of?(String)
      arg = regs[arg]
    end
    case op
    when "set"
      regs[reg] = arg
      pc += 1
    when "add"
      regs[reg] += arg
      pc += 1
    when "mul"
      mul_count += 1
      regs[reg] *= arg
      pc += 1
    when "mod"
      regs[reg] %= arg
      pc += 1
    when "snd"
      last = regs[reg]
      pc += 1
    when "rcv"
      if regs[reg] != 0
        return last
      end
      pc += 1
    when "jgz"
      if regs[reg] != 0
        pc += arg
      else
        pc += 1
      end
    end
  end

  nil
end

example = <<-EX
set a 1
add a 2
mul a a
mod a 5
snd a
set a 0
rcv a
jgz a -1
set a 1
jgz a -2
EX

part 1
with(:solution)
try example, 4
try puzzle_input

part 2

example = <<-EX
snd 1
snd 2
snd p
rcv a
rcv b
rcv c
rcv d
EX

class Program
  attr_reader :sent_counter
  attr_reader :debug
  attr_reader :received
  attr_reader :state

  def initialize(prog, pid, debug = false)
    @prog = prog
    @pid = pid
    @debug = debug
    @regs = Hash.new(0)
    @regs["p"] = pid
    @pc = 0
    @sent = []
    @sent_counter = 0
    @received = []

    @state = :run # :wait, :exit
  end

  def waiting?
    @state == :wait && @received.empty?
  end

  def dead?
    @state == :dead
  end

  def sent
    if @sent.length > 0
      @sent.shift
    else
      nil
    end
  end

  def <<(value)
    @received << value
  end

  def run
    return if dead?

    while @pc >= 0 && @pc < @prog.length
      op, reg, arg = *@prog[@pc]
      puts "#{@pid}: #{@pc} : #{@prog[@pc].compact.join(" ")} #{@regs.map{|k, v| "#{k}:#{v}"}.join(" ") }" if debug
      if arg && arg.kind_of?(String)
        arg = @regs[arg]
      end
      case op
      when "set"
        @regs[reg] = arg
        @pc += 1
      when "add"
        @regs[reg] += arg
        @pc += 1
      when "mul"
        @regs[reg] *= arg
        @pc += 1
      when "mod"
        @regs[reg] %= arg
        @pc += 1
      when "snd"
        if reg =~ /\d/
          val = reg.to_i
        else
          val = @regs[reg]
        end
        puts "  sending #{val}" if debug
        @sent << val
        @sent_counter += 1
        @pc += 1
      when "rcv"
        if @received.empty?
          @state = :wait
          return
        else
          @regs[reg] = @received.shift
          puts "  received #{@regs[reg]}" if debug
          state = :run
        end
        @pc += 1
      when "jgz"
        if reg =~ /\d/
          val = reg.to_i
        else
          val = @regs[reg]
        end
        if val > 0
          @pc += arg
        else
          @pc += 1
        end
      else
        raise "what"
      end
    end

    puts "  dead: pc is #{@pc}" if debug
    @state = :dead
  end
end

def parallel(input, debug = false)
  prog = input.lines.map do |line|
    op, reg, operand = line.strip.split(" ", 3)
    [
      op,
      reg,
      operand =~ /\d+/ ? operand.to_i : operand
    ]
  end

  zero, one = Program.new(prog, 0, debug), Program.new(prog, 1, debug)

  n = 0
  loop do
    zero.run
    one.run

    while value = zero.sent
      one << value
    end
    while value = one.sent
      zero << value
    end

    if (zero.waiting? || zero.dead?) && (one.waiting? || one.dead?)
      puts "done!"
      break
    end
    n += 1

    if debug
      puts "----- #{n} -----"
      puts "  #{zero.sent_counter} #{zero.state} #{zero.received}"
      puts "  #{one.sent_counter} #{one.state} #{one.received}"
    end
  end
  puts

  one.sent_counter
end

with(:parallel, true)
try example, 3
with(:parallel)
try puzzle_input
