require_relative "../toolkit"

def compute_registers(input)
  registers = Hash.new(0)
  max = 0
  input.lines.map do |line|
    _, reg, op, val, a, cond, b = *(/(\w+) (\w+) (-?\d+) if (\w+) ([!=<>]{1,2}) (-?\d+)/).match(line)
    if reg
      comp_val = registers[a]
      if condition(registers, comp_val, cond, b.to_i)
        case op
        when "inc"
          registers[reg] += val.to_i
        when "dec"
          registers[reg] -= val.to_i
        else
          raise "unknown op #{op}"
        end
      end
    else
      raise "what: #{line.inspect}"
    end
    max = [registers.values.max, max].compact.max
  end

  yield registers, max
end

def condition(registers, a, cond, b)
  case cond
  when ">"
    a > b
  when ">="
    a >= b
  when "<"
    a < b
  when "<="
    a <= b
  when "=="
    a == b
  when "!="
    a != b
  else
    raise "unknown condition #{cond}"
  end
end

example = <<-EX
b inc 5 if a > 1
a inc 1 if b < 5
c dec -10 if a >= 1
c inc -20 if c == 10
EX

part 1
with(:compute_registers) { |rs, max| rs.values.max }
try example, 1
try puzzle_input

part 2
with(:compute_registers) { |rs, max| max }
try example, 10
try puzzle_input

