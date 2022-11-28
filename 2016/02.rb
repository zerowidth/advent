require_relative "../toolkit"

def part1(input)
  x = 1
  y = 1
  digits = input.lines.map do |line|
    line.each_char do |char|
      case char
      when "U"
        y = [y - 1, 0].max
      when "D"
        y = [y + 1, 2].min
      when "L"
        x = [x - 1, 0].max
      when "R"
        x = [x + 1, 2].min
      end
    end
    x + (y * 3) + 1
  end
  dpp digits
  digits.map(&:to_s).join("")
end

def part2(input)
  keypad = [
    [nil, nil, "1", nil, nil],
    [nil, "2", "3", "4", nil],
    %w[5 6 7 8 9],
    [nil, "A", "B", "C", nil],
    [nil, nil, "D", nil, nil]
  ]
  x = 0
  y = 2
  digits = input.lines.map do |line|
    line.each_char do |char|
      case char
      when "U"
        ny = [y - 1, 0].max
        y = ny if keypad[ny][x]
      when "D"
        ny = [y + 1, 4].min
        y = ny if keypad[ny][x]
      when "L"
        nx = [x - 1, 0].max
        x = nx if keypad[y][nx]
      when "R"
        nx = [x + 1, 4].min
        x = nx if keypad[y][nx]
      end
    end
    keypad[y][x]
  end
  dpp digits
  digits.join
end

ex1 = <<EX
ULL
RRDDD
LURDL
UUUUD
EX

part 1
with :part1
debug!
try ex1, "1985"
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, "5DB3"
no_debug!
try puzzle_input
