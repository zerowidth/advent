require_relative "../toolkit"

def part1(input)
  lines = input.lines_of(:numbers)
  # find points where more than one line overlaps

  # brute force: all points for all lines
  points = Hash.of_array
  lines.each.with_index do |(x1, y1, x2, y2), i|
    next unless x1 == x2 || y1 == y2

    if x1 == x2
      [y1, y2].min.upto([y1, y2].max) { |y| points[[x1, y]] << i }
    else
      [x1, x2].min.upto([x1, x2].max) { |x| points[[x, y1]] << i }
    end
  end
  points.count { |p, vs| vs.length > 1 }
end

def part2(input)
  lines = input.lines_of(:numbers)
  # find points where more than one line overlaps

  # brute force: all points for all lines
  points = Hash.of_array
  lines.each.with_index do |(x1, y1, x2, y2), i|
    if x1 == x2
      [y1, y2].min.upto([y1, y2].max) { |y| points[[x1, y]] << i }
    elsif y1 == y2
      [x1, x2].min.upto([x1, x2].max) { |x| points[[x, y1]] << i }
    else
      # diagonals
      debug "line #{i} from #{x1} #{y1} to #{x2} #{y2}"
      dx = x1 > x2 ? -1 : 1
      dy = y1 > y2 ? -1 : 1
      x, y = x1, y1
      points[[x, y]] << i
      loop do
        debug "  #{x} #{y}"
        x += dx
        y += dy
        points[[x, y]] << i
        break if x == x2 && y == y2
      end
    end
  end
  points.count { |_p, vs| vs.length > 1 }
end

ex1 = <<EX
0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2
EX

part 1
with :part1
debug!
try ex1, 5
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, 12
# no_debug!
try puzzle_input # not 18115
