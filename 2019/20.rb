require_relative "../toolkit"
require_relative "./grid"
require_relative "./graph_search"

ex1 = <<-EX
         A
         A
  #######.#########
  #######.........#
  #######.#######.#
  #######.#######.#
  #######.#######.#
  #####  B    ###.#
BC...##  C    ###.#
  ##.##       ###.#
  ##...DE  F  ###.#
  #####    G  ###.#
  #########.#####.#
DE..#######...###.#
  #.#########.###.#
FG..#########.....#
  ###########.#####
             Z
             Z
EX

ex2 = <<-EX
                   A
                   A
  #################.#############
  #.#...#...................#.#.#
  #.#.#.###.###.###.#########.#.#
  #.#.#.......#...#.....#.#.#...#
  #.#########.###.#####.#.#.###.#
  #.............#.#.....#.......#
  ###.###########.###.#####.#.#.#
  #.....#        A   C    #.#.#.#
  #######        S   P    #####.#
  #.#...#                 #......VT
  #.#.#.#                 #.#####
  #...#.#               YN....#.#
  #.###.#                 #####.#
DI....#.#                 #.....#
  #####.#                 #.###.#
ZZ......#               QG....#..AS
  ###.###                 #######
JO..#.#.#                 #.....#
  #.#.#.#                 ###.#.#
  #...#..DI             BU....#..LF
  #####.#                 #.#####
YN......#               VT..#....QG
  #.###.#                 #.###.#
  #.#...#                 #.....#
  ###.###    J L     J    #.#.###
  #.....#    O F     P    #.#...#
  #.###.#####.#.#####.#####.###.#
  #...#.#.#...#.....#.....#.#...#
  #.#####.###.###.#.#.#########.#
  #...#.#.....#...#.#.#.#.....#.#
  #.###.#####.###.###.#.#.#######
  #.#.........#...#.............#
  #########.###.###.#############
           B   J   C
           U   P   P
EX

ex3 = <<-EX
             Z L X W       C
             Z P Q B       K
  ###########.#.#.#.#######.###############
  #...#.......#.#.......#.#.......#.#.#...#
  ###.#.#.#.#.#.#.#.###.#.#.#######.#.#.###
  #.#...#.#.#...#.#.#...#...#...#.#.......#
  #.###.#######.###.###.#.###.###.#.#######
  #...#.......#.#...#...#.............#...#
  #.#########.#######.#.#######.#######.###
  #...#.#    F       R I       Z    #.#.#.#
  #.###.#    D       E C       H    #.#.#.#
  #.#...#                           #...#.#
  #.###.#                           #.###.#
  #.#....OA                       WB..#.#..ZH
  #.###.#                           #.#.#.#
CJ......#                           #.....#
  #######                           #######
  #.#....CK                         #......IC
  #.###.#                           #.###.#
  #.....#                           #...#.#
  ###.###                           #.#.#.#
XF....#.#                         RF..#.#.#
  #####.#                           #######
  #......CJ                       NM..#...#
  ###.#.#                           #.###.#
RE....#.#                           #......RF
  ###.###        X   X       L      #.#.#.#
  #.....#        F   Q       P      #.#.#.#
  ###.###########.###.#######.#########.###
  #.....#...#.....#.......#...#.....#.#...#
  #####.#.###.#######.#######.###.###.#.#.#
  #.......#.......#.#.#.#.#...#...#...#.#.#
  #####.###.#####.#.#.#.#.###.###.#.###.###
  #.......#.....#.#...#...............#...#
  #############.#.#.###.###################
               A O F   N
               A A D   M
EX

def pair(a,b)
  Set.new [a,b]
end

def parse(input)
  grid = Grid.new
  input.split("\n").each.with_index do |line, y|
    line.each_char.with_index do |v, x|
      grid[Vec[x, y]] = v if v != " "
    end
  end

  portals = {}
  char = /[A-Z]/
  grid.each do |p, v|
    next unless v =~ char
    if grid[p + Vec[1, 0]] =~ char # has a char to the right
      portal = v + grid[p + Vec[1, 0]]
      if grid[p + Vec[2, 0]] == "." # portal is to the right
        portals[p + Vec[2, 0]] = portal
      else
        portals[p + Vec[-1, 0]] = portal
      end
    elsif grid[p + Vec[0, 1]] =~ /[A-Z]/
      portal = v + grid[p + Vec[0, 1]]
      if grid[p + Vec[0, 2]] == "." # portal below
        portals[p + Vec[0, 2]] = portal
      else
        portals[p + Vec[0, -1]] = portal
      end
    end
  end

  portal_pairs = Hash.new { |h, k| h[k] = [] }
  portals.each do |pos, name|
    portal_pairs[name] << pos
  end

  [grid, portals, portal_pairs]
end

def part1(input)
  grid, portals, portal_pairs = parse(input)
  # STDERR.puts "portals: #{(portals).inspect}"
  # STDERR.puts "portal_pairs: #{(portal_pairs).inspect}"

  start = portal_pairs["AA"].first
  goal = portal_pairs["ZZ"].first

  search = GraphSearch.new do |s|
    s.neighbors = ->(pos) do
      ns = grid.adjacent_points(pos, diagonal: false).select do |p|
        grid[p] == "."
      end
      if portal = portals[pos]
        pair = portal_pairs[portal]
        if other = (pos == pair[0] ? pair[1] : pair[0])
          ns << other
        end
      end
      ns
    end
    s.cost = ->(a, b) { 1 }
    # s.debug = true
  end

  # puts grid.to_s

  if found = search.path(start: start, goal: goal)
    found[1]
  end
end

def part2(input)
  grid, portals, portal_pairs = parse(input)

  STDERR.puts "grid.width: #{(grid.width).inspect}"
  STDERR.puts "grid.height: #{(grid.height).inspect}"

  # psuedo-3-dimensional
  start = [portal_pairs["AA"].first, 0]
  goal = [portal_pairs["ZZ"].first, 0]

  search = GraphSearch.new do |s|
    s.neighbors = ->(pos) do
      xy, z = *pos

      ns = grid.adjacent_points(xy, diagonal: false).select do |p|
        grid[p] == "."
      end.map { |n| [n, z] }

      if portal = portals[xy]
        pair = portal_pairs[portal]
        if other = (xy == pair[0] ? pair[1] : pair[0])
          # are we _on_ an outer ring, traveling "down" a layer?
          outer_ring = xy.x == 2 || xy.y == 2 ||
            xy.x == (grid.width - 2 - 1) ||
            xy.y == (grid.height - 2 - 1)
          if (outer_ring && z > 0) || !outer_ring
            # STDERR.puts "including portal #{portal}"
            delta_z = outer_ring ? -1 : 1
            ns << [other, z + delta_z]
          end
        elsif portal == "ZZ" && z == 0
          # STDERR.puts "including portal ZZ"
          ns << [portal_pairs["ZZ"][0], 0]
        end
      end

      ns
    end
    s.break_if = ->(cost_so_far, best) do
      if best && (best > 0) && (cost_so_far > (best * 2))
        STDERR.puts "BREAK: #{best} / #{cost_so_far}"
        true
      else
        # gotta stop somewhere
        if cost_so_far > (grid.width * grid.height / 2)
          STDERR.puts "giving up at cost #{cost_so_far}"
          true
        end
      end
    end
    s.cost = ->(a, b) { 1 }
    # s.debug = true
  end

  # puts grid.to_s

  if found = search.path(start: start, goal: goal)
    found[1]
  end
end

part 1
with :part1
try ex1, expect: 23
try ex2, expect: 58
try puzzle_input

part 2
with :part2
try ex1, 26
# try ex2, nil
# try ex3, 396
# try puzzle_input
