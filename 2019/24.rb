require_relative "../toolkit"
require_relative "./grid"

ex1 = <<-EX
....#
#..#.
#..##
..#..
#....
EX

def parse_grid(input)
  grid = Grid.new
  input.split("\n").each.with_index do |line, y|
    line.each_char.with_index do |char, x|
      grid[Vec[x, y]] = char
    end
  end
  grid
end

def part1(input)
  grid = parse_grid input

  count = 0
  seen = Set.new
  loop do
    count += 1

    new = Grid.new
    grid.each do |p, v|
      bugs = grid.adjacent_values(p, diagonal: false).count("#")
      if v == "#"
        new[p] = bugs == 1 ? "#" : "."
      else
        new[p] = [1, 2].include?(bugs) ? "#" : "."
      end
    end

    grid = new

    # puts count
    # puts "-----"
    # puts grid.to_s
    # puts

    break if seen.include? grid.to_s

    seen.add grid.to_s
  end

  grid.map do |p, v|
    v == "#" ? 2**(5 * p.y + p.x) : 0
  end.sum
end

def empty_recursive
  grid = Grid.new
  0.upto(4) do |x|
    0.upto(4) do |y|
      grid.set Vec[x, y], "."
    end
  end
  grid.set Vec[2, 2], "?"
  grid
end

def print_grids(grids)
  grids.keys.sort.each do |num|
    next unless grids[num].map { |_, v| v }.count("#").positive?

    puts "--- #{num} ---"
    puts grids[num].to_s(pad: 0)
  end
end

def part2(input, iterations)
  start_grid = parse_grid input
  start_grid.set(Vec[2, 2], "?")
  grids = { 0 => start_grid }

  iterations.times do |iteration|
    # warn "iteration #{iteration}"

    # make room for expansion inward and outward
    grids[grids.keys.min - 1] = empty_recursive unless grids[grids.keys.min] == empty_recursive
    grids[grids.keys.max + 1] = empty_recursive unless grids[grids.keys.max] == empty_recursive

    new_grids = {}

    grids.sort_by { |d, _g| d }.each do |depth, grid|
      # warn "grid #{depth}:"
      # warn grid.to_s(pad: 0, prefix: 2)

      new_grid = empty_recursive
      grid.each do |p, v|
        next if p == Vec[2, 2] # ignore the center
        # warn "#{depth} @ #{p} #{grid[p]}"

        bugs = 0
        grid.adjacent_points(p, diagonal: false).each do |np|
          # warn "  #{p}->#{np} #{grid[np]}"
          if grid[np] == "#"
            bugs += 1
            # warn "    1 bug"
          elsif grid[np].nil? && (layer = grids[depth - 1]) # looking "out"
            # warn "    looking out:"
            # warn layer.to_s(pad: 0, prefix: 4)

            if np.x == -1 # "left"
              # warn "  [1, 2]: #{layer[Vec[1, 2]]} (left)"
              bugs += 1 if layer[Vec[1, 2]] == "#"
            elsif np.x == 5 # "right"
              # warn "  [3, 2]: #{layer[Vec[3, 2]]} (right)"
              bugs += 1 if layer[Vec[3, 2]] == "#"
            elsif np.y == -1 # "up"
              # warn "  [2, 1]: #{layer[Vec[2, 1]]} (up)"
              bugs += 1 if layer[Vec[2, 1]] == "#"
            elsif np.y == 5 # "down"
              # warn "  [2, 3]: #{layer[Vec[2, 3]]} (down)"
              bugs += 1 if layer[Vec[2, 3]] == "#"
            end
            # warn "    #{bugs} bugs (out)"
          elsif grid[np] == "?" && (layer = grids[depth + 1]) # looking "in"
            # warn "    looking in:"
            # warn layer.to_s(pad: 0, prefix: 4)
            case p.x
            when 1
              bugs += layer.column(0).count { |_lp, lv| lv == "#" }
            when 3
              bugs += layer.column(4).count { |_lp, lv| lv == "#" }
            end
            case p.y
            when 1
              bugs += layer.row(0).count { |_lp, lv| lv == "#" }
            when 3
              bugs += layer.row(4).count { |_lp, lv| lv == "#" }
            end
            # warn "    #{bugs} bugs (in)"
          end
        end

        if v == "#"
          # A bug dies (becoming an empty space) unless there is exactly one
          # bug adjacent to it.
          new_grid[p] = bugs == 1 ? "#" : "."
          # warn "  -> dies"
        else
          # An empty space becomes infested with a bug if exactly one or two
          # bugs are adjacent to it.
          infested = [1, 2].include?(bugs)
          new_grid[p] = infested ? "#" : "."
          # warn "  -> #{infested ? "infested" : "left alone"}"
        end
      end

      new_grids[depth] = new_grid
    end

    grids = new_grids
  end

  # warn "===== after ====="
  # print_grids grids

  result = grids
  .select { |_depth, grid| grid.map { |_, v| v }.count("#").positive? }
  .sort_by { |depth, _grid| depth }.map(&:last)
  block_given? ? yield(result) : result
end

part 1
with :part1
try ex1, expect: 2_129_920
try puzzle_input

# clear_term
part 2
with :part2 do |grids|
  grids.map(&:to_s).join("\n")
end
expected = <<-GRIDS
..#..
.#.#.
..?.#
.#.#.
..#..

...#.
...##
..?..
...##
...#.

#.#..
.#...
..?..
.#...
#.#..

.#.##
....#
..?.#
...##
.###.

#..##
...##
..?..
...#.
.####

.#...
.#.##
.#?..
.....
.....

.##..
#..##
..?.#
##.##
#####

###..
##.#.
#.?..
.#.##
#.#..

..###
.....
#.?..
#....
#...#

.###.
#..#.
#.?..
##.#.
.....

####.
#..#.
#.?#.
####.
.....
GRIDS

try ex1, 10, expect: expected

with :part2, 200
try(puzzle_input) { |grids| grids.map { |g| g.count { |_p, v| v == "#" } }.sum }
