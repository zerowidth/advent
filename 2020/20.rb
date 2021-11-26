require_relative "../toolkit"

ex1 = <<-EX
Tile 2311:
..##.#..#.
##..#.....
#...##..#.
####.#...#
##.##.###.
##...#.###
.#.#.#..##
..#....#..
###...#.#.
..###..###

Tile 1951:
#.##...##.
#.####...#
.....#..##
#...######
.##.#....#
.###.#####
###.##.##.
.###....#.
..#.#..#.#
#...##.#..

Tile 1171:
####...##.
#..##.#..#
##.#..#.#.
.###.####.
..###.####
.##....##.
.#...####.
#.##.####.
####..#...
.....##...

Tile 1427:
###.##.#..
.#..#.##..
.#.##.#..#
#.#.#.##.#
....#...##
...##..##.
...#.#####
.#.####.#.
..#..###.#
..##.#..#.

Tile 1489:
##.#.#....
..##...#..
.##..##...
..#...#...
#####...#.
#..#.#.#.#
...#.#.#..
##.#...##.
..##.##.##
###.##.#..

Tile 2473:
#....####.
#..#.##...
#.##..#...
######.#.#
.#...#.#.#
.#########
.###.#..#.
########.#
##...##.#.
..###.#.#.

Tile 2971:
..#.#....#
#...###...
#.#.###...
##.##..#..
.#####..##
.#..####.#
#..#.#..#.
..####.###
..#.#.###.
...#.#.#.#

Tile 2729:
...#.#.#.#
####.#....
..#.#.....
....#..#.#
.##..##.#.
.#.####...
####.#.#..
##.####...
##..#.##..
#.##...##.

Tile 3079:
#.#.#####.
.#..######
..#.......
######....
####.#..#.
.#...#.##.
#.#####.##
..#.###...
..#.......
..#.###...
EX

class Tile
  attr_reader :id, :lines

  def self.from_string(input)
    input.split("\n").first =~ /Tile (\d+):/
    id = $1

    lines = []

    input.split("\n").drop(1).each do |line|
      lines << line.chomp.chars
    end

    new id, lines
  end

  def initialize(id, lines)
    @id = id
    @lines = lines
  end

  def to_number(chars)
    chars.join.gsub(".", "0").gsub("#", "1").to_i(2)
  end

  def edges
    [
      # top
      to_number(lines.first),
      to_number(lines.first.reverse),
      # right
      to_number(lines.flat_map(&:last)),
      to_number(lines.flat_map(&:last).reverse),
      # bottom
      to_number(lines.last),
      to_number(lines.last.reverse),
      # left
      to_number(lines.flat_map(&:first)),
      to_number(lines.flat_map(&:first).reverse),
    ]
  end

  def right_edge
    to_number(lines.flat_map(&:last))
  end

  def top_edge
    to_number(lines.first)
  end

  def left_edge
    to_number(lines.flat_map(&:first))
  end

  def bottom_edge
    to_number(lines.last)
  end

  def rotate!
    @lines = (0...@lines.length).map do |n|
      @lines.map { |l| l[n] }.reverse
    end
  end

  def flip_vertical!
    @lines = @lines.reverse
  end

  def flip_horizontal!
    @lines = @lines.map(&:reverse)
  end

  def edge_ids
    edges.each_slice(2).map(&:sort).map { |pair| pair.join("-") }
  end

  def matches(patterns)
    found = [] # array of line, starting index
    lines.each_cons(patterns.length).with_index.each do |ls, start|
      indices = ls.zip(patterns).flat_map { |l, p| l.join.indices(p).to_a }
      indices.tally.select { |i, v| v == patterns.length }.each do |i, v|
        found << [start, i]
      end
    end
    found
  end

  def to_s
    "tile #{@id}\n" + @lines.map { |l| l.join }.join("\n")
  end
end

def part1(input)
  tiles = input.split("\n\n").map { |tile| Tile.from_string(tile) }

  # each corner will only be able to match with two other tiles, leaving two
  # edges unmatched.
  by_edge_id = Hash.of_array
  tiles.each do |tile|
    tile.edge_ids.each { |eid| by_edge_id[eid] << tile }
  end

  corners = tiles.select do |candidate|
    candidate.edge_ids.reject { |eid| by_edge_id[eid].length == 1 }.length == 2
  end

  corners.map(&:id).map(&:to_i).reduce(1, &:*)
end

SEA_MONSTER = <<~MONSTER
                  #
#    ##    ##    ###
 #  #  #  #  #  #
MONSTER

def part2(input)
  tiles = input.split("\n\n").map { |tile| Tile.from_string(tile) }
  # gotta actually line up the tiles now, in the right orientation

  by_edge_id = Hash.of_array
  tiles.each do |tile|
    tile.edge_ids.each { |eid| by_edge_id[eid] << tile }
  end

  by_edge_id.sort_by(&:first).each do |eid, ts|
    debug "edge #{eid} tiles #{ts.map(&:id)}"
  end

  # first find a corner:
  corner = tiles.detect do |candidate|
    candidate.edge_ids.reject { |eid| by_edge_id[eid].length == 1 }.length == 2
  end

  # rotate/flip the corner until the unmatched edges are to the left/top:
  debug "orienting corner #{corner.id}"
  3.times do
    need_match = corner.edge_ids.reject { |eid| by_edge_id[eid].length == 1 }
    indexes = need_match.map { |u| corner.edge_ids.index(u) }
    debug "  indexes #{indexes} for edges #{corner.edge_ids} #{corner.edges}"
    break if indexes == [1, 2]

    if indexes.first != 1
      debug "rotating"
      corner.rotate!
    elsif indexes.last != 2
      debug "flipping vertical"
      corner.flip_vertical!
    end
  end

  grid = Array.new(tiles.length)
  grid[0] = corner

  width = tiles.length # will update this once we find the edge
  y = 0
  x = 1

  while y < tiles.length / width
    while x < width
      next if x == 0 && y == 0

      debug "x #{x} y #{y}"

      if x.positive? # looking to our left
        left = grid[(y * width) + x - 1]
        edge_id = left.edge_ids[1]
        debug "looking right for match for #{edge_id} oriented to match #{left.right_edge}"
        tile = by_edge_id[edge_id].detect { |t| t != left }
        debug "got tile #{tile.id} with edges #{tile.edge_ids} #{tile.edges}"

        # rotate the tile until its left edge id matches
        while tile.edge_ids[3] != edge_id
          debug "  rotating"
          tile.rotate!
        end

        if tile.left_edge != left.right_edge
          debug "  flipping vertically"
          tile.flip_vertical!
        end

      else # looking upward
        top = grid[(y - 1) * width + x]
        edge_id = top.edge_ids[2]
        debug "looking upward for match for #{edge_id} oriented #{top.bottom_edge}"
        tile = by_edge_id[edge_id].detect { |t| t != top }
        debug "got tile #{tile.id} with edges #{tile.edge_ids} #{tile.edges}"

        # rotate the tile until its top edge id matches
        while tile.edge_ids[0] != edge_id
          debug "  rotating"
          tile.rotate!
        end

        if tile.top_edge != top.bottom_edge
          debug "  flipping horizontally"
          tile.flip_horizontal!
        end
      end

      debug "  -> tile #{tile.edges}"
      grid[x + y * width] = tile

      # now look right: if there are no matching tiles, we've hit the edge.
      if by_edge_id[tile.edge_ids[1]].length == 1
        debug "found the edge at x = #{x}"
        width = x + 1
        x = 0
        break
      end

      x += 1
    end

    debug "next row"
    y += 1
    x = 0
  end

  # take the grid and remove the edges, then make a new tile from it
  lines = []
  grid.each_slice(width) do |row|
    len = row.first.lines.length
    1.upto(len - 2) do |i|
      lines << row.flat_map { |t| t.lines[i][1..-2] }
    end
  end

  tile = Tile.new("monster", lines)

  # finally, let's go hunting for sea monsters
  monster = SEA_MONSTER.split("\n").map { |line| Regexp.new(line.gsub(" ", ".")) }
  monster_blocks = SEA_MONSTER.count("#")
  tile_blocks = tile.lines.map { |line| line.join.count("#") }.sum

  # for each rotation: check, check horizontal flip, then flip back, then rotate
  debug "searching for monsters"
  4.times do
    break if tile.matches(monster).length > 0

    debug "flipping"
    tile.flip_horizontal!
    break if tile.matches(monster).length > 0

    tile.flip_horizontal!
    debug "rotating"
    tile.rotate!
  end

  matched = tile.matches(monster).length
  debug "found #{matched} monsters"
  tile_blocks - matched * monster_blocks
end

part 1
with :part1
debug!
try ex1, expect: 20899048083289
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, expect: 273
debug!
no_debug!
try puzzle_input
