require_relative "../toolkit"

def jump_escape(input)
  offsets = input.lines.map do |line|
    line.to_i
  end
  p = 0
  out = offsets.length
  steps = 0

  loop do
    break if p < 0 || p >= out
    o = offsets[p]
    offsets[p] = yield o
    p += o
    steps += 1
  end

  steps
end

example = <<-EX
0
3
0
1
-3
EX

part 1
with(:jump_escape) { |v| v + 1 }
try example, 5
try puzzle_input

part 2
with(:jump_escape) { |v| v >= 3 ? v - 1 : v + 1 }
try example, 10
try puzzle_input
