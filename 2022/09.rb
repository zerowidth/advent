require_relative "../toolkit"

DIRS = {
  "R" => [1, 0],
  "L" => [-1, 0],
  "U" => [0, 1],
  "D" => [0, -1]
}

def draw(head, tail, visited)
  return unless debug?
  points = {}
  visited.each do |point|
    points[point] = "#"
  end
  points[[0, 0]] = "s"
  points[tail] = "T"
  points[head] = "H"
  min_x = points.keys.map(&:first).min
  max_x = points.keys.map(&:first).max
  min_y = points.keys.map(&:last).min
  max_y = points.keys.map(&:last).max
  max_y.downto(min_y) do |y|
    min_x.upto(max_x) do |x|
      print points.fetch([x, y], ".")
    end
    puts
  end
  puts
end

def part1(input)
  visited = Set.new([[0, 0]])
  head = [0, 0]
  tail = [0, 0]
  input.lines.each do |instr|
    debug "--- #{instr} ---"
    dir, dist = instr.split(" ")
    dist = dist.to_i

    dist.times do
      delta = DIRS.fetch(dir)
      head = [head[0] + delta[0], head[1] + delta[1]]
      # now, resolve where the tail needs to go
      # start with the minimum distance first, then the other
      dx = head[0] - tail[0]
      dy = head[1] - tail[1]

      if dx.abs > 1 && dy != 0
        # debug "  DY dx #{dx} dy #{dy}"
        tail[1] += dy
      elsif dy.abs > 1 && dx != 0
        # debug "  DX dx #{dx} dy #{dy}"
        tail[0] += dx
      end

      if head[1] - tail[1] > 1
        tail[1] += 1
      elsif head[1] - tail[1] < -1
        tail[1] -= 1
      end
      if head[0] - tail[0] > 1
        tail[0] += 1
      elsif head[0] - tail[0] < -1
        tail[0] -= 1
      end

      visited << tail.dup # omfg
      # debug "  #{head} #{tail}"
      draw head, tail, visited
    end
  end
  visited.size
end

def part2(input)
  input.lines
end

ex1 = <<EX
R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2
EX

ex2 = <<EX
R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20
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
try ex1, nil
no_debug!
try puzzle_input
