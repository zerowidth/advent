require_relative "../toolkit"
require_relative "../2019/grid"

ex1 = <<-EX
.#.#.#
...##.
#....#
..#...
#.#..#
####..
EX

ex2 = <<-EX
o#.#.o
...##.
#....#
..#...
#.#..#
o###.o
EX

def next_grid(grid)
  new_grid = Grid.new
  grid.each do |p, v|
    on = grid.adjacent_values(p).count("#")
    if v == "#"
      new_grid[p] = [2, 3].include?(on) ? "#" : "."
    else
      new_grid[p] = on == 3 ? "#" : "."
    end
  end

  new_grid
end

def part1(input, steps)
  grid = Grid.parse(input)

  steps.times do
    grid = next_grid(grid)
    print "."
  end
  puts

  grid.to_s
end

def fix_lights(grid)
  w = grid.width
  h = grid.height
  grid[Vec[0, 0]] = "#"
  grid[Vec[0, h]] = "#"
  grid[Vec[w, 0]] = "#"
  grid[Vec[w, h]] = "#"
end

def part2(input, steps)
  grid = Grid.parse(input)
  fix_lights(grid)

  steps.times do
    grid = next_grid(grid)
    fix_lights(grid)
    print "."
  end
  puts

  grid.to_s
end

part 1
with :part1, 1
try ex1, expect: <<-EX
..##..
..##.#
...##.
......
#.....
#.##..
EX

with :part1, 4
try ex1, expect: 4 do |grid|
  grid.count("#")
end
with :part1, 100
try puzzle_input do |grid|
  grid.count("#")
end

part 2
with :part2, 5
try ex1, expect: <<-EX
##.###
.##..#
.##...
.##...
#.#...
##...#
EX
# try ex2, nil

with :part2, 100
try puzzle_input do |grid|
  grid.count("#")
end
