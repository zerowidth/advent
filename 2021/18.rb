require_relative "../toolkit"
require "json"

def sum(a, b)
  reduce "[#{a},#{b}]"
end

# returns true if num was modified
def explode(num)
  # first, look for explode, count left brackets
  depth = 0
  pos = nil
  num.chars.each.with_index do |c, i|
    case c
    when "["
      depth += 1
    when "]"
      depth -= 1
    end

    if depth == 5 && num[i, 5] =~ /\[\d,\d\]/
      pos = i
      break
    end
  end

  return false unless pos

  pair = num[pos, 5]
  values = JSON.parse(pair)

  if debug?
    debug_num = num.dup
    debug_num[pos, 5] = pair.colorize(:blue)
    debug "explode: #{debug_num}"
  end

  # find number to the left, if any
  left = num.indices(/\d+/).select { |i| i < pos }.last
  # find number to the right, if any
  right = num.indices(/\d+/).detect { |i| i > (pos + 5) }

  # right to left, update string:
  num[right..] = num[right..].sub(/\d+/) { |rnum| (rnum.to_i + values.last).to_s } if right
  num[pos, 5] = "0"
  num[left..] = num[left..].sub(/\d+/) { |lnum| (lnum.to_i + values.first).to_s } if left
  true
end

def split(num)
  return false unless (pos = num.index(/\d\d/))

  value = num[pos, 2]

  if debug?
    debug_num = num.dup
    debug_num[pos, 2] = value.colorize(:yellow)
    debug "split:   #{debug_num}"
  end

  value = value.to_i
  num[pos, 2] = "[#{value / 2},#{(value / 2) + (value % 2)}]"

  true
end

def reduce(num)
  changed = false
  loop do
    break unless explode(num) || split(num)
  end
  debug "reduced: #{num}"
  num
end

def sum_list(input)
  input.lines.reduce { |a, b| sum(a, b) }
end

def mag(num)

end

def part1(input)
  reduce(input.lines)
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
with :reduce
try "[[[[[9,8],1],2],3],4]", "[[[[0,9],2],3],4]"
try "[7,[6,[5,[4,[3,2]]]]]", "[7,[6,[5,[7,0]]]]"
try "[[6,[5,[4,[3,2]]]],1]", "[[6,[5,[7,0]]],3]"
try "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]", "[[3,[2,[8,0]]],[9,[5,[7,0]]]]"
with :sum_list
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
