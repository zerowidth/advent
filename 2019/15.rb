require_relative "../toolkit"
require_relative "./intcode"
require_relative "./simple_grid"

DIRS = {
  [ 0,  1] => 1, # north ("south" on screen)
  [ 0, -1] => 2, # south ("north" on screen)
  [-1,  0] => 3, # west
  [ 1,  0] => 4, # east
}
TO_VEC = DIRS.invert
BOT = [nil, "v", "^", "<", ">"]

def add(point, vec)
  point.zip(vec).map(&:sum)
end

def path_to_dir(start, path)
  path.map do |pos|
    next if pos == start
    diff = pos.zip(start).map { |a, b| a - b }
    start = pos
    DIRS.fetch(diff)
  end.compact
end

# explores the grid defined by the input program
def explore(input)
  cpu = Intcode.from_program(input)
  grid = SimpleGrid.new
  dir = 1
  pos = [0, 0]
  grid.set(*pos, "•")
  not_a_wall = ->(p) { grid.at(*p) != "#" }
  unexplored = ->(p) { grid.at(*p).nil? }
  path = []

  (1..).each do |n|
    # puts "----- #{n} -----"
    # grid.set(*pos, BOT[dir])
    # puts grid.to_s(0)
    # grid.set(*pos, "•")

    if path.empty?
      # find nearest unexplored node
      path = grid.path(pos, filter: not_a_wall, diagonal: false, &unexplored)
      if !path
        STDERR.puts "all done!"
        break
      end

      path.each { |p| grid.set(*p, "+") } # for debugging
      path = path_to_dir(pos, path)
    end

    dir = path.shift
    cpu << dir
    cpu.run
    out = cpu.output.shift

    case out
    when 0 # hit a wall
      grid.set(*add(pos, TO_VEC[dir]), "#")
    when 1 # droid moved successfully
      pos = add(pos, TO_VEC[dir])
      grid.set(*pos, "•")
    when 2 # droid found the oxygen panel
      pos = add(pos, TO_VEC[dir])
      grid.set(*pos, "@")
    else
      raise "wtf? #{out}"
    end
  end

  grid
end

def open_neighbors(grid, point)
  grid.adjacent_points(*point, diagonal: false).select do |p|
    v = grid.at(*p)
    v != "#" && v != "O"
  end
end

def part1(input)
  grid = explore(input)
  not_a_wall = ->(p) { grid.at(*p) != "#" }
  oxygen = grid.find { |x, y, v| v == "@" }.first(2)
  puts "found oxygen at #{oxygen}, finding path..."
  path = grid.path([0,0], goal: oxygen, filter: not_a_wall, diagonal: false)
  puts grid.to_s(pad: 0)
  path.length
end

def part2(input)
  grid = explore(input)
  oxygen = grid.find { |x, y, v| v == "@" }.first(2)

  grid.set(*oxygen, "O")
  frontier = open_neighbors(grid, oxygen)

  # now, flood fill the thing, one minute (step) at a time
  minutes = 0
  until frontier.empty?
    minutes += 1

    next_to_fill = []
    frontier.each do |point|
      grid.set(*point, "O")
    end
    frontier.each do |point|
      next_to_fill += open_neighbors(grid, point)
    end
    frontier = next_to_fill

    # puts "----- #{minutes} -----"
    # puts grid.to_s(pad: 0)
    # puts "frontier: #{frontier}"
    # sleep 0.1
  end

  minutes
end


part 1
with :part1
try puzzle_input

part 2
with :part2
try puzzle_input
