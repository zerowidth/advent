require_relative "../toolkit"

def turn_right(dir)
  case dir
  when [1, 0]
    [0, 1]
  when [0, 1]
    [-1, 0]
  when [-1, 0]
    [0, -1]
  when [0, -1]
    [1, 0]
  end
end

def turn_left(dir)
  case dir
  when [1, 0]
    [0, -1]
  when [0, 1]
    [1, 0]
  when [-1, 0]
    [0, 1]
  when [0, -1]
    [-1, 0]
  end
end

def reverse(dir)
  [-dir[0], -dir[1]]
end

def parse(input)
  grid = Hash.new { |h, k| h[k] = "." }

  map = input.lines.map do |line|
    line.rstrip.chars
  end
  center = map.size / 2
  0.upto(map.first.length - 1) do |y|
    0.upto(map.first.length - 1) do |x|
      grid[ [x-center, y-center] ] = map[y][x]
    end
  end

  grid
end

def show(grid, current=nil)
  xmin = grid.keys.map(&:first).min
  xmax = grid.keys.map(&:first).max
  ymin = grid.keys.map(&:last).min
  ymax = grid.keys.map(&:last).max

  ymin.upto(ymax) do |y|
    xmin.upto(xmax) do |x|
      pos = [x, y]
      char = grid[pos]
      if current == pos
        char = char.red
      end
      print char
    end
    puts
  end
end

def solution(input, bursts, debug = false)
  grid = parse(input)
  pos = [0, 0]
  dir = [0, -1]
  infections = 0
  show(grid, pos) if debug

  bursts.times do
    puts "---" if debug
    if grid[pos] == "#"
      dir = turn_right(dir)
      grid[pos] = "."
    else
      dir = turn_left(dir)
      grid[pos] = "#"
      infections += 1
    end
    pos[0] += dir[0]
    pos[1] += dir[1]

    show(grid, pos) if debug
  end

  show(grid, pos) if !debug

  infections
end

def complex(input, bursts, debug = false)
  grid = parse(input)
  pos = [0, 0]
  dir = [0, -1]
  infections = 0
  show(grid, pos) if debug

  bursts.times do |burst|
    if debug
      puts "---"
    else
      print "#{burst}/#{bursts}\r" if burst % 10000 == 0
    end
    case grid[pos]
    when "#"
      dir = turn_right(dir)
      grid[pos] = "F"
    when "."
      dir = turn_left(dir)
      grid[pos] = "W"
    when "W"
      grid[pos] = "#"
      infections += 1
    when "F"
      dir = reverse(dir)
      grid[pos] = "."
    end
    pos[0] += dir[0]
    pos[1] += dir[1]

    show(grid, pos) if debug
  end

  show(grid, pos) if !debug

  infections
end

example = <<-EX
..#
#..
...
EX

part 1
with(:solution, 7, true)
try example, 5
with(:solution, 70, false)
try example, 41
# with(:solution, 10000, false)
# try example, 5587
# try puzzle_input

# part 2
# with(:complex, 8, true)
# try example, 1
# with(:complex, 100)
# try example, 26
# with(:complex, 10000000)
# try example, 2511944
# try puzzle_input
