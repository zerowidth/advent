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
    "[#{left},#{right}]"
  end
end

def push_leftmost(num, value)
  return num + value if num.value?

  [push_leftmost(num.left, value), num.right]
end

def push_rightmost(num, value)
  return num + value if num.value?

  [num.left, push_rightmost(num.right, value)]
end

# return a number, a value to push left, a value to push right, and a bool for "was changed"
def explode(num, depth: 0)
  return num, 0, 0, false if num.value?

  # debug ("  " * depth) + "#{num} #{depth}"

  if depth == 4 && num.pair? && num.left.value? && num.right.value?
    debug "exploding #{num}"
    return 0, num.left, num.right, true
  end

  left, lv, rv, changed = explode(num.left, depth: depth + 1)
  if changed # leftmost node exploded, we need to push rv to the next leftmost right of us
    # debug "pushing #{rv} to next leftmost in #{num.right}"
    right = push_leftmost(num.right, rv)
    # debug "  #{right}"
    return [left, right], lv, 0, true
  end

  right, lv, rv, changed = explode(num.right, depth: depth + 1)
  if changed # right node exploded, push lv to the next rightmost left of us
    # debug "push #{lv} to next rightmost in #{left}"
    left = push_rightmost(left, lv)
    # debug "  #{left}"
    return [left, right], 0, rv, true
  end

  [[left, right], 0, 0, false]
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
    num, _, _, exploded = explode(num)
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

def magnitude(num)
  return num if num.value?

  (magnitude(num.left) * 3) + (magnitude(num.right) * 2)
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
  magnitude(sum)
end

def part2(input)
  nums = input.lines.map_with(:parse)
  nums.combination(2).map { |a, b| magnitude(sum(a, b)) }.max
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
[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
[7,[5,[[3,8],[1,4]]]]
[[2,[2,2]],[8,[8,1]]]
[2,9]
[1,[[[9,3],9],[[9,0],[0,7]]]]
[[[5,[7,4]],7],1]
[[[[4,2],2],6],[8,7]]
EX

ex5 = <<EX
[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
[[[5,[2,8]],4],[5,[[9,9],0]]]
[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
[[[[5,4],[7,7]],8],[[8,3],8]]
[[9,3],[[9,9],[6,[4,9]]]]
[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
EX

part 1
debug!
with :reduce_line
try "[[[[[9,8],1],2],3],4]", "[[[[0,9],2],3],4]"
try "[7,[6,[5,[4,[3,2]]]]]", "[7,[6,[5,[7,0]]]]"
try "[[6,[5,[4,[3,2]]]],1]", "[[6,[5,[7,0]]],3]"
# try "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]", "[[3,[2,[8,0]]],[9,[5,[7,0]]]]"
with :sum_lines
try ex1, "[[[[1,1],[2,2]],[3,3]],[4,4]]"
try ex2, "[[[[3,0],[5,3]],[4,4]],[5,5]]"
try ex3, "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]"
no_debug!
try ex4, "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]"
try ex5, "[[[[6,6],[7,6]],[[7,7],[7,0]]],[[[7,7],[7,7]],[[7,8],[9,9]]]]"
with :part1
try ex5, 4140
no_debug!
try puzzle_input

part 2
with :part2
no_debug!
try puzzle_input
