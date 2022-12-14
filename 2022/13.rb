require_relative "../toolkit"

def compare(left, right, depth: 0)
  debug " " * depth * 2 + "comparing #{left.inspect} to #{right.inspect}"
  if left.is_a?(Array) && right.is_a?(Array)
    left = left.dup
    right = right.dup
    debug " " * depth * 2 + "comparing arrays #{left.inspect} to #{right.inspect}"
    loop do
      l = left.shift
      r = right.shift
      return 0 if l.nil? && r.nil?
      return 1 if r.nil?
      return -1 if l.nil?
      value = compare(l, r, depth: depth + 1)
      next if value == 0
      return value
    end
    0
  elsif left.is_a?(Integer) && right.is_a?(Integer)
    left <=> right
  elsif left.is_a?(Array) && right.is_a?(Integer)
    compare(left, [right], depth: depth + 1)
  elsif left.is_a?(Integer) && right.is_a?(Array)
    compare([left], right, depth: depth + 1)
  end
end

def part1(input)
  pairs = input.sections.map do |section|
    section.lines.map { |line| JSON.parse(line) }
  end
  pairs.map do |pair|
    debug
    x = compare(pair.first, pair.last)
    debug "  -> #{x}"
    x
  end.tap { |v| dpp v }.map.with_index do |valid, i|
    valid < 0 ? (i + 1) : 0
  end.sum
end

def part2(input)
  dividers = [
    [[2]],
    [[6]]
  ]
  input << "\n#{dividers.first.inspect}\n#{dividers.last.inspect}\n"
  packets = input.sections.flat_map do |section|
    section.lines.map { |line| eval(line) }
  end
  sorted = packets.sort { |a, b| compare(a, b) }.tap { |v| dpp v }
  dividers.map { |d| sorted.index(d) + 1 }.reduce(&:*)
end

ex1 = <<EX
[1,1,3,1,1]
[1,1,5,1,1]

[[1],[2,3,4]]
[[1],4]

[9]
[[8,7,6]]

[[4,4],4,4]
[[4,4],4,4,4]

[7,7,7,7]
[7,7,7]

[]
[3]

[[[]]]
[[]]

[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]
EX

part 1
with :part1
debug!
try ex1, 13
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, 140
no_debug!
try puzzle_input
