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

  regs = {}
  ('a'..'h').each { |k| regs[k] = 0 }
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
    when "sub"
      regs[reg] -= arg
      pc += 1
    when "mul"
      mul_count += 1
      regs[reg] *= arg
      pc += 1
    when "jnz"
      if regs[reg] != 0
        pc += arg
      else
        pc += 1
      end
    end
  end

  mul_count
end

def main
  h = 0

  b = 105700
  c = 105700 + 17000

  loop do
    f = 1

    d = 2
    loop do
      e = 2
      loop do
        f = 0 if (d * e) - b == 0
        e += 1
        break if e - b == 0
      end

      d += 1
      break if d - b == 0
    end

    if f == 0
      h += 1
    end

    break if b - c == 0
    b += 17
  end

  h
end

def translated(*args)
  h = 0
  105700.step(by: 17, to: 105700 + 17000) do |b|
    prime = true
    2.upto(b-1) do |d|
      if b % d == 0
        prime = false
        break
      end
    end
    h += 1 unless prime
  end
  h
end

part 1
with(:solution)
try puzzle_input

part 2
with(:translated)
try nil
