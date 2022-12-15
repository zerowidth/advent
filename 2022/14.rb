require_relative "../toolkit"
require_relative "../grid"

def parse(input)
  grid = Grid.new(&:infinite)
  input.lines.map do |line|
    coords = line.split(" -> ").map { |c| c.split(",").map(&:to_i) }
    coords.each_cons(2) do |from, to|
      from[0].to(to[0]) do |x|
        from[1].to(to[1]) do |y|
          grid[x, y] = "#"
        end
      end
    end
  end
  grid
end

def part1(input)
  grid = parse(input)
  max_y = grid.each.map { |_, y, _| y }.max

  loop do
    sand = [500, 0]
    loop do
      if grid[sand[0], sand[1] + 1].nil?
        sand[1] += 1
      elsif grid[sand[0] - 1, sand[1] + 1].nil?
        sand[0] -= 1
        sand[1] += 1
      elsif grid[sand[0] + 1, sand[1] + 1].nil?
        sand[0] += 1
        sand[1] += 1
      else
        break
      end

      break if sand[1] > max_y
    end

    # exit entirely if we fall off the edge
    break if sand[1] > max_y

    grid.set(*sand, "o") if grid.get(*sand).nil?
    debug
    debug grid
  end

  grid.count { |_, _, v| v == "o" }
end

def part2(input)
  grid = parse(input)
  floor = grid.each.map { |_, y, _| y }.max + 2

  to_fill = [[500, 0]]
  while (fill = to_fill.shift)
    next unless grid[*fill].nil?
    next if fill[1] == floor

    to_fill << [fill[0], fill[1] + 1]
    to_fill << [fill[0] - 1, fill[1] + 1]
    to_fill << [fill[0] + 1, fill[1] + 1]

    grid[*fill] = "o"

    debug
    debug grid
  end

  grid.count { |_, _, v| v == "o" }
end

ex1 = <<EX
498,4 -> 498,6 -> 496,6
503,4 -> 502,4 -> 502,9 -> 494,9
EX

part 1
with :part1
debug!
try ex1, 24
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, 93
no_debug!
try puzzle_input
