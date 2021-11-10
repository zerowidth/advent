require_relative "../toolkit"
require_relative "../2019/grid"

ex1 = <<-EX
L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL
EX

def part1(input)
  seats = Grid.parse(input)

  n = 0
  loop do
    puts "--- #{n} ---"
    updated = Grid.new
    seats.each do |pos, seat|
      if seat == "."
        updated[pos] = seat
        next
      end

      filled = seats.adjacent_values(pos).count("#")
      if seat == "L" && filled == 0
        updated[pos] = "#"
      elsif seat == "#" && filled >= 4
        updated[pos] = "L"
      else
        updated[pos] = seat
      end
    end

    if updated == seats
      puts "stable after #{n} iterations"
      break
    end

    seats = updated
    n += 1
  end

  seats.values.count("#")
end

def part2(input)
  seats = Grid.parse(input)

  n = 0
  loop do
    puts "--- #{n} ---"
    updated = Grid.new
    seats.each do |pos, seat|
      if seat == "."
        updated[pos] = seat
        next
      end

      filled = 0
      [-1, 0, 1].each do |dx|
        [-1, 0, 1].each do |dy|
          next if dx.zero? && dy.zero?

          dir = Vec[dx, dy]
          cur = pos + dir
          cur += dir while seats[cur] && seats[cur] == "."
          filled += 1 if seats[cur] == "#"
        end
      end

      if seat == "L" && filled == 0
        updated[pos] = "#"
      elsif seat == "#" && filled >= 5
        updated[pos] = "L"
      else
        updated[pos] = seat
      end
    end

    if updated == seats
      puts "stable after #{n} iterations"
      break
    end

    seats = updated
    n += 1
  end

  seats.values.count("#")
end

part 1
with :part1
try ex1, expect: 37
try puzzle_input

part 2
with :part2
try ex1, expect: 26
try puzzle_input
