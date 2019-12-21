require_relative "../toolkit"
require_relative "./intcode"

ex1 = <<-EX
#.......................................
.#......................................
..##....................................
...###..................................
....###.................................
.....####...............................
......#####.............................
......######............................
.......#######..........................
........########........................
.........#########......................
..........#########.....................
...........##########...................
...........############.................
............############................
.............#############..............
..............##############............
...............###############..........
................###############.........
................#################.......
.................########OOOOOOOOOO.....
..................#######OOOOOOOOOO#....
...................######OOOOOOOOOO###..
....................#####OOOOOOOOOO#####
.....................####OOOOOOOOOO#####
.....................####OOOOOOOOOO#####
......................###OOOOOOOOOO#####
.......................##OOOOOOOOOO#####
........................#OOOOOOOOOO#####
.........................OOOOOOOOOO#####
..........................##############
..........................##############
...........................#############
............................############
.............................###########
EX

def part1(input)
  program = input.split(",").map(&:to_i)

  out = []
  0.upto(49) do |y|
    0.upto(49) do |x|
      cpu = Intcode.new program, [x, y]
      cpu.run
      out += cpu.output
    end
  end

  @grid = Grid.new
  out.each_slice(50).with_index do |row, y|
    row.each.with_index do |v, x|
      @grid.set x, y, v == 0 ? "." : "#"
    end
  end
  puts @grid.to_s(pad: 0)

  out.count(1)
end

def part2_intcode(input, square_size:, debug: false)
  program = input.split(",").map(&:to_i)
  grid = Grid.new do |x, y|
    cpu = Intcode.new program, [x, y]
    cpu.run
    cpu.output.first == 0 ? "." : "#"
  end
  part2 grid, square_size: square_size, debug: debug
end

def part2_parsed(input, square_size:, debug: false)
  grid = Grid.new

  input.strip.split("\n").each.with_index do |row, y|
    row.each_char.with_index do |v, x|
      grid.set x, y, v == "." ? "." : "#"
    end
  end

  part2 grid, square_size: square_size, debug: debug
end

def part2(grid, square_size:, debug: false)
  left = [0, 10]

  # find left edge of the beam
  loop do
    if grid.at(*left) == "#"
      break
    end
    left = left.zip([1,0]).map(&:sum)
  end

  expansions = [[0,1],[1,1],[1,0]]

  print_grid = ->(mark: false) do
    return unless debug
    lv = grid.at(*left)
    grid.set(*left, "L" + lv) if mark
    puts "-" * grid.width
    puts grid.to_s(pad: 0)
    grid.set(*left, lv)
    # sleep 0.1
  end

  loop do
    expansions.each do |dir|
      pos = left.zip(dir).map(&:sum)
      if grid.at(*pos) == "#"
        left = pos
        break
      end
    end
    found = grid.at(left[0] + square_size - 1, left[1] - square_size + 1) == "#"
    print_grid.call mark: true
    break if found
  end

  # fill in the square, for visualization
  left[0].upto(left[0]+square_size-1) do |x|
    (left[1] - square_size + 1).upto(left[1]) do |y|
      grid.set(x, y, "O")
    end
  end
  print_grid.call mark: false
  left[0] * 10000 + left[1] - square_size + 1
end

part 1
with :part1
# try puzzle_input

part 2
with :part2_intcode, square_size: 5, debug: false
try puzzle_input
with :part2_parsed, square_size: 10, debug: false
try ex1, 250020
with :part2_intcode, square_size: 100
try puzzle_input
