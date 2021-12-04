require_relative "../toolkit"

def parse_wires(input)
  wires = {}

  input.lines.each do |line|
    case line
    when /^(\w+) -> (\w+)/
      wires[$2] = [:get, $1]
    when /^(\w+) AND (\w+) -> (\w+)/
      wires[$3] = [:and, $1, $2]
    when /^(\w+) OR (\w+) -> (\w+)/
      wires[$3] = [:or, $1, $2]
    when /^NOT (\w+) -> (\w+)/
      wires[$2] = [:not, $1]
    when /^(\w+) LSHIFT (\d+) -> (\w+)/
      wires[$3] = [:lshift, $1, $2]
    when /^(\w+) RSHIFT (\d+) -> (\w+)/
      wires[$3] = [:rshift, $1, $2]
    else
      raise "what? #{line.inspect}"
    end
  end
  wires
end

def circuit(input)
  wires = parse_wires(input)
  filtered = {}
  wires.each_key { |k| filtered[k.to_sym] = resolve(wires, {}, k) }
  filtered
end

def resolve(wires, memo, which)
  if which =~ /^\d+$/
    return which.to_i
  end
  if memo[which]
    return memo[which]
  end
  wire = wires[which]
  op = wire.first
  val = case op
    when :v
      wire.last
    when :and
      resolve(wires, memo, wire[1]) & resolve(wires, memo, wire[2])
    when :or
      resolve(wires, memo, wire[1]) | resolve(wires, memo, wire[2])
    when :lshift
      (resolve(wires, memo, wire[1]) << resolve(wires, memo, wire[2])) & 0xFFFF
    when :rshift
      resolve(wires, memo, wire[1]) >> resolve(wires, memo, wire[2])
    when :not
      ~resolve(wires, memo, wire[1]) & 0xFFFF
    when :get
      resolve(wires, memo, wire[1])
    else
      raise "what? #{wire.inspect}"
    end
  memo[which] = val
  val
end

def part1(input)
  circuit(input)
end

def part2(input)
  wires = parse_wires(input)
  values = {}
  wires.each_key { |k| values[k.to_sym] = resolve(wires, {}, k) }
  puts "setting wire b #{wires["b"].inspect} to #{values[:a]}"
  wires["b"] = [:get, values[:a].to_s]
  resolve(wires, {}, "a")
end

example = <<-S
123 -> x
456 -> y
x AND y -> d
x OR y -> e
x LSHIFT 2 -> f
y RSHIFT 2 -> g
NOT x -> h
NOT y -> i
S
reordered = <<-S
x AND y -> d
x OR y -> e
x LSHIFT 2 -> f
y RSHIFT 2 -> g
NOT x -> h
NOT y -> i
123 -> x
456 -> y
S
expected = {
  d: 72,
  e: 507,
  f: 492,
  g: 114,
  h: 65412,
  i: 65079,
  x: 123,
  y: 456,
}

part 1
with :circuit
try example, expected
try reordered, expected
with :part1
try(puzzle_input) { |values| values[:a] }

part 2
with :part2
try puzzle_input
