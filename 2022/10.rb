require_relative "../toolkit"

def cpu(instructions)
  Enumerator.new do |y|
    x = 1
    instructions.each do |instruction|
      case instruction
      when "noop"
        y << x
      when /addx (-?\d+)/
        y << x # first cycle leaves x unchanged
        y << x # yield "during" cycle
        x += $1.to_i # then change at the end
      else
        raise "wtf"
      end
    end
  end
end

def part1(input)
  values = cpu(input.lines).to_a
  [20, 60, 100, 140, 180, 220].map do |i|
    debug "i=#{i} value=#{values[i-1]}"
    i * values[i-1]
  end.sum
end

def part2(input)
  grid = 6.times.map { Array.new(40, ".") }
  values = cpu(input.lines).map.with_index do |value, pixel|
    y = pixel / 40
    x = pixel % 40
    if value >= x - 1 && value <= x + 1
      grid[y][x] = "#"
    end
  end
  (grid.map(&:join).join("\n") + "\n").tap { |g| puts g }
end

ex1 = <<EX
noop
addx 3
addx -5
EX

ex2 = <<EX
addx 15
addx -11
addx 6
addx -3
addx 5
addx -1
addx -8
addx 13
addx 4
noop
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx -35
addx 1
addx 24
addx -19
addx 1
addx 16
addx -11
noop
noop
addx 21
addx -15
noop
noop
addx -3
addx 9
addx 1
addx -3
addx 8
addx 1
addx 5
noop
noop
noop
noop
noop
addx -36
noop
addx 1
addx 7
noop
noop
noop
addx 2
addx 6
noop
noop
noop
noop
noop
addx 1
noop
noop
addx 7
addx 1
noop
addx -13
addx 13
addx 7
noop
addx 1
addx -33
noop
noop
noop
addx 2
noop
noop
noop
addx 8
noop
addx -1
addx 2
addx 1
noop
addx 17
addx -9
addx 1
addx 1
addx -3
addx 11
noop
noop
addx 1
noop
addx 1
noop
noop
addx -13
addx -19
addx 1
addx 3
addx 26
addx -30
addx 12
addx -1
addx 3
addx 1
noop
noop
noop
addx -9
addx 18
addx 1
addx 2
noop
noop
addx 9
noop
noop
noop
addx -1
addx 2
addx -37
addx 1
addx 3
noop
addx 15
addx -21
addx 22
addx -6
addx 1
noop
addx 2
addx 1
noop
addx -10
noop
noop
addx 20
addx 1
addx 2
addx 2
addx -6
addx -11
noop
noop
noop
EX

part 1
with :part1
debug!
try ex2, 13140
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex2, <<EX
##..##..##..##..##..##..##..##..##..##..
###...###...###...###...###...###...###.
####....####....####....####....####....
#####.....#####.....#####.....#####.....
######......######......######......####
#######.......#######.......#######.....
EX
no_debug!
try puzzle_input
