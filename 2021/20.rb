require_relative "../toolkit"

def region(grid, x, y)
  [
    [x - 1, y - 1],
    [x, y - 1],
    [x + 1, y - 1],
    [x - 1, y],
    [x, y],
    [x + 1, y],
    [x - 1, y + 1],
    [x, y + 1],
    [x + 1, y + 1],
  ].map do |p|
    grid[p]
  end
end

def draw(grid)
  return unless debug?
  xmin = grid.keys.min_by(&:first).first - 3
  xmax = grid.keys.max_by(&:first).first + 3
  ymin = grid.keys.min_by(&:last).last - 3
  ymax = grid.keys.max_by(&:last).last + 3
  ymin.upto(ymax) do |y|
    xmin.upto(xmax) do |x|
      print grid[[x, y]]
    end
    puts
  end
  puts
end

def part1(input, iterations:, cut_border: false, drop_infinite: false)
  algorithm = input.sections.first.lines.join

  debug "algorithm: #{algorithm}"
  
  if drop_infinite
    algorithm[0] = "."
  end

  grid = Hash.new(".")
  input.sections.last.lines.each_with_index do |line, row|
    line.chars.each_with_index do |char, col|
      grid[[col, row]] = char if char == "#"
    end
  end

  draw grid

  iterations.times_with_progress(title: "iterating") do |iteration|
    expand = 3
    xmin = grid.keys.min_by(&:first).first - expand
    xmax = grid.keys.max_by(&:first).first + expand
    ymin = grid.keys.min_by(&:last).last - expand
    ymax = grid.keys.max_by(&:last).last + expand

    new_grid = Hash.new(".")

    xmin.upto(xmax) do |x|
      ymin.upto(ymax) do |y|
        i = region(grid, x, y).join.tr(".#", "01").to_i(2)
        value = algorithm[i]
        new_grid[[x, y]] = "#" if value == "#"
      end
    end

    grid = new_grid
    debug "iteration #{iteration}"
    draw grid

    next if iteration.even? || iteration.zero? || !cut_border

    # here's the trick: algorithm 0 of the puzzle input says "make all .'s
    # #'s forever" but then: algorithm 511 says "make regions of # into ." so:
    # there's going to be a stripe of values around the edge of the image.
    # cut off the border to make it go away.
    # empirically: with expand = 9, can cut 9 #'s off on each side
    xmin = grid.keys.min_by(&:first).first
    xmax = grid.keys.max_by(&:first).first
    ymin = grid.keys.min_by(&:last).last
    ymax = grid.keys.max_by(&:last).last
    ymin.upto(ymin + expand) do |y|
      xmin.upto(xmax) { |x| grid[[x, y]] = "x" }
    end
    ymax.downto(ymax - expand + 1) do |y|
      xmin.upto(xmax) { |x| grid[[x, y]] = "x" }
    end
    (ymin + expand - 1).upto(ymax - expand + 1) do |y|
      xmin.upto(xmin + expand) { |x| grid[[x, y]] = "x" }
      xmax.downto(xmax - expand) { |x| grid[[x, y]] = "x" }
    end

    # draw grid
    grid = grid.delete_if { |_, v| v == "x" }
  end

  # draw grid

  grid.values.count("#")
end

def part2(input)
  input.lines
end

ex1 = <<EX
..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..##
#..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###
.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#.
.#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#.....
.#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#..
...####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.....
..##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

#..#.
#....
##..#
..#..
..###
EX

part 1
with :part1, iterations: 2
debug!
# try ex1, 35
# no_debug!
with :part1, iterations: 2, cut_border: true
try puzzle_input # 5765

part 2
with :part1, iterations: 50, cut_border: true
debug!
# try ex1, nil
no_debug!
try puzzle_input # 18509
