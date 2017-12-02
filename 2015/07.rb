require_relative "../toolkit"

def circuit(input, values)
  wires = {}

  input.lines.each do |line|
    case line
    when /^(\d+) -> (\w+)/
      wires[$2] = $1.to_i
    when /^(\w+) AND (\w+) -> (\w+)/
      wires[$3] = wires[$1] & wires[$2]
    when /^(\w+) OR (\w+) -> (\w+)/
      wires[$3] = wires[$1] | wires[$2]
    when /^NOT (\w+) -> (\w+)/
      wires[$2] = ~wires[$1] & 0xFFFF
    when /^(\w+) LSHIFT (\d+) -> (\w+)/
      wires[$3] = (wires[$1] << $2.to_i) & 0xFFFF
    when /^(\w+) RSHIFT (\d+) -> (\w+)/
      wires[$3] = (wires[$1] >> $2.to_i)
    end
  end

  filtered = {}
  values.each { |v| filtered[v.to_sym] = wires[v] }
  filtered
end

with(:circuit, %w(d e f g h i x y))

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

try example, expected
try reordered, expected
# try puzzle_input
