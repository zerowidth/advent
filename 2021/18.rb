require_relative "../toolkit"
require "json"

class Integer
  def pair?
    false
  end

  def value?
    true
  end
end

class Array
  def left
    self[0]
  end

  def left=(value)
    self[0] = value
  end

  def right
    self[1]
  end

  def right=(value)
    self[1] = value
  end

  def pair?
    true
  end

  def value?
    false
  end

  def to_s
    "[#{left.to_s},#{right.to_s}]"
  end
end

def _explode(node, depth: 0, push_left: 0, push_right: 0)
  debug ("  " * depth) + "at #{node} depth #{depth} <-#{push_left} #{push_right}->"
  return [node, 0, 0, false] if node.value?

  if node.pair? && depth == 4
    debug "explode: #{node}"
    return 0, node.left, node.right, true
  end

  lv = rv = 0
  if node.left.pair?
    node.left, lv, rv, changed = _explode(node.left, depth: depth + 1, push_left: push_left, push_right: push_right)
    if node.right.value?
      node.right += rv
      rv = 0
    end

    return node, lv, rv, true if changed
  elsif push_left > 0
    node += push_left
    changed = true
    return node, 0, 0, true
  end

  if node.right.pair?
    node.right, lv, rv, c = _explode(node.right, depth: depth + 1, push_left: push_left, push_right: push_right)
    changed ||= c
    if node.left.value?
      node.left += lv
      lv = 0
    end
  elsif push_right > 0
    node += push_right
    return node, 0, 0, true
  end

  [node, 0, 0, false]
end

def explode(num)
  debug "exploding #{num}"
  num, _lv, _rv, changed = _explode(num)
  [num, changed]
end

def split(num)
  if num.value?
    if num > 9
      debug "split: #{num}"
      return [num / 2, (num / 2) + (num % 2)], true
    end

    return num, false
  end

  left, changed = split(num.left)
  return [left, num.right], true if changed

  right, changed = split(num.right)
  [[left, right], changed]
end

def reduce(num)
  debug "reducing #{num}"
  loop do
    num, exploded = explode(num)
    next if exploded

    num, was_split = split(num)
    break unless was_split
  end
  debug "reduced: #{num}"
  num
end

def sum(a, b)
  reduce [a, b]
end

def parse(line)
  JSON.parse(line)
end

# for testing reduce
def reduce_line(input)
  reduce(parse(input)).to_s
end

# for testing sums
def sum_lines(input)
  input.lines.map_with(:parse).reduce { |a, b| sum(a, b) }.to_s
end

def part1(input)
  sum = input.lines.map_with(:parse).reduce { |a, b| sum(a, b) }
end

def part2(input)
  input.lines
end

ex1 = <<EX
[1,1]
[2,2]
[3,3]
[4,4]
EX

ex2 = <<EX
[1,1]
[2,2]
[3,3]
[4,4]
[5,5]
EX

ex3 = <<EX
[[[[4,3],4],4],[7,[[8,4],9]]]
[1,1]
EX

ex4 = <<EX
[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
EX

part 1
debug!
with :reduce_line
try "[[[[[9,8],1],2],3],4]", "[[[[0,9],2],3],4]"
try "[7,[6,[5,[4,[3,2]]]]]", "[7,[6,[5,[7,0]]]]"
try "[[6,[5,[4,[3,2]]]],1]", "[[6,[5,[7,0]]],3]"
try "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]", "[[3,[2,[8,0]]],[9,[5,[7,0]]]]"
with :sum_lines
try ex1, "[[[[1,1],[2,2]],[3,3]],[4,4]]"
try ex2, "[[[[3,0],[5,3]],[4,4]],[5,5]]"
try ex3, "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]"
try ex4, "[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]"
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, nil
no_debug!
try puzzle_input
