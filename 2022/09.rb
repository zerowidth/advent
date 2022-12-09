require_relative "../toolkit"

DIRS = {
  "R" => [1, 0],
  "L" => [-1, 0],
  "U" => [0, 1],
  "D" => [0, -1]
}

def draw(positions, visited)
  return unless debug?
  points = {}
  visited.each do |point|
    points[point] = "#"
  end
  points[[0, 0]] = "s"
  positions.each do |knot, point|
    points[point] = knot
  end
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

def resolve(head, tail)
  head = head.dup
  new_tail = tail.dup
  dx = head[0] - tail[0]
  dy = head[1] - tail[1]

  # both need to move diagonal
  if dx.abs > 1 && dy.abs > 1
    new_tail[0] += (dx / dx.abs)
    new_tail[1] += (dy / dy.abs)
  elsif dx.abs > 1 && dy != 0
    new_tail[1] += dy
  elsif dy.abs > 1 && dx != 0
    new_tail[0] += dx
  end

  if head[1] - new_tail[1] > 1
    new_tail[1] += 1
  elsif head[1] - new_tail[1] < -1
    new_tail[1] -= 1
  end
  if head[0] - new_tail[0] > 1
    new_tail[0] += 1
  elsif head[0] - new_tail[0] < -1
    new_tail[0] -= 1
  end

  # debug "    #{tail} to #{head} (#{dx}, #{dy}) -> #{new_tail}"
  new_tail
end

def tail_visits(knots, instructions)
  visited = Set.new([[0, 0]])
  positions = {}
  knots.each do |knot|
    positions[knot] = [0, 0]
  end

  instructions.each do |instr|
    debug "--- #{instr} ---"
    dir, dist = instr.split(" ")
    dist = dist.to_i

    dist.times do
      delta = DIRS.fetch(dir)
      head = positions[knots.first]
      positions[knots.first] = [head[0] + delta[0], head[1] + delta[1]]
      knots.each_cons(2) do |k1, k2|
        debug "  #{k2} -> #{k1}"
        positions[k2] = resolve positions[k1].dup, positions[k2].dup
      end

      visited << positions[knots.last].dup
      draw positions, visited
    end
  end

  visited
end

def part1(input)
  visited = tail_visits %w[H T], input.lines
  visited.size
end

def part2(input)
  visited = tail_visits %w[H 1 2 3 4 5 6 7 8 9], input.lines
  visited.size
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
try ex1, 1
try ex2, 36
no_debug!
try puzzle_input
