require_relative "../toolkit"

# https://www.redblobgames.com/grids/hexagons/#coordinates-cube

DIRS = {
  "e" => [1, 0, -1],
  "se" => [0, 1, -1],
  "sw" => [-1, 1, 0],
  "w" => [-1, 0, 1],
  "nw" => [0, -1, 1],
  "ne" => [1, -1, 0]
}

def flip_tiles(input)
  grid = {}

  input.lines.each do |tile|
    instructions = tile.scan(/se|sw|ne|nw|e|w/)
    debug "tile: #{instructions}"

    pos = [0, 0, 0] # q, r, s coords
    instructions.each do |instruction|
      dir = DIRS.fetch(instruction)
      pos = pos.zip(dir).map(&:sum)
    end
    grid[pos] = !grid[pos]
  end
  grid
end

def neighbors(pos)
  DIRS.values.map do |dir|
    pos.zip(dir).map(&:sum)
  end
end

def part1(input)
  flip_tiles(input).values.count { |x| x }
end

def part2(input, iterations:)
  floor = Set.new
  flip_tiles(input).each do |pos, black|
    floor << pos if black
  end

  iterations.times_with_progress do |n|
    to_evaluate = Set.new
    floor.each do |pos|
      to_evaluate.merge(neighbors(pos))
    end

    next_floor = Set.new
    to_evaluate.each do |pos|
      count = neighbors(pos).count { |neighbor| floor.include? neighbor }
      if floor.include?(pos) # black
        unless count == 0 || count > 2
          next_floor << pos
        end
      elsif count == 2 # white
        next_floor << pos
      end
    end

    floor = next_floor

    debug "day #{n + 1}: #{floor.size}"
  end

  floor.length
end

ex1 = <<-EX
sesenwnenenewseeswwswswwnenewsewsw
neeenesenwnwwswnenewnwwsewnenwseswesw
seswneswswsenwwnwse
nwnwneseeswswnenewneswwnewseswneseene
swweswneswnenwsewnwneneseenw
eesenwseswswnenwswnwnwsewwnwsene
sewnenenenesenwsewnenwwwse
wenwwweseeeweswwwnwwe
wsweesenenewnwwnwsenewsenwwsesesenwne
neeswseenwwswnwswswnw
nenwswwsewswnenenewsenwsenwnesesenew
enewnwewneswsewnwswenweswnenwsenwsw
sweneswneswneneenwnewenewwneswswnese
swwesenesewenwneswnwwneseswwne
enesenwswwswneneswsenwnewswseenwsese
wnwnesenesenenwwnenwsewesewsesesew
nenewswnwewswnenesenwnesewesw
eneswnwswnwsenenwnwnwwseeswneewsenese
neswnwewnwnwseenwseesewsenwsweewe
wseweeenwnesenwwwswnew
EX

part 1
with :part1
debug!
try ex1, expect: 10
no_debug!
try puzzle_input

part 2
with :part2, iterations: 10
debug!
try ex1, expect: 37
no_debug!
with :part2, iterations: 100
try ex1, expect: 2208
try puzzle_input
