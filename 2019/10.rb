require_relative "../toolkit"

class Asteroids
  def initialize(map)
    @points = {}

    map.split.each.with_index do |line, y|
      line.split("").each.with_index do |char, x|
        if char == "#"
          @points[[x,y]] = 0
        end
      end
    end
  end

  def by_visibility
    keys = @points.keys
    keys.map do |from|
      unblocked = by_vector(from).map do |vec, points|
        point = points.sort_by { |point| taxicab(from, point.last) }.first
        [point, vec]
      end
      [from, unblocked.length]
    end.sort_by(&:last)
  end

  def vaporizations_from(station)
    by_angle = (@points.keys - [station]).map do |target|
      # this calculates the direction in _screen_ space, not coordinate space
      # since the Y axis is inverted from Math.atan2 &c. "Up" in screen space is
      # [0, -1]
      #
      dir = [ target[0] - station[0], target[1] - station[1] ]
      angle = Math.atan2(dir[1], dir[0])
      angle += Math::PI/2 # rotate world 90 degrees (laser rotates left 90)
      angle += Math::PI * 2 if angle < 0
      [angle, target]
    end
    grouped = by_angle.group_by(&:first).map do |angle, targets|
      targets = targets.map(&:last).sort_by do |point|
        taxicab(station, point) # good enough to differentiate
      end
      [angle, targets]
    end.sort_by(&:first)
    grouped[0].last.zip(*grouped[1..].map(&:last)).flatten(1).compact
  end

  # Returns { [dx, dy] -> [ [[x,y], [dx,dy]], ... ] }
  def by_vector(from)
    @points.keys.map do |to|
      next if from == to
      [to, vector(from, to)]
    end.compact.group_by(&:last)
  end

  def width
    @width ||= @points.keys.map(&:first).max
  end

  def height
    @height ||= @points.keys.map(&:last).max
  end

  def taxicab(a, b)
    (a[0]-b[0]).abs + (a[1]-b[1]).abs
  end

  def vector(a, b)
    minimize [a[0]-b[0], a[1]-b[1]]
  end

  def minimize(vector)
    x, y = *vector
    gcd = x.gcd(y)
    [x/gcd, y/gcd]
  end

  def unit_vector(a, b)
    Math.sqrt((a[0] - b[0])**2, (a[1]-b[1])**2)
  end
end

def best_observer(input)
  Asteroids.new(input).by_visibility.last
end

def vaporizations(input)
  asteroids = Asteroids.new(input)
  station = asteroids.by_visibility.last.first
  zapped = asteroids.vaporizations_from(station)
  [station, zapped]
end

ex1 = <<-EX
.#..#
.....
#####
....#
...##
EX

ex2 = <<-EX
......#.#.
#..#.#....
..#######.
.#.#.###..
.#..#.....
..#....#.#
#..#....#.
.##.#..###
##...#..#.
.#....####
EX

ex3 = <<-EX
#.#...#.#.
.###....#.
.#....#...
##.#.#.#.#
....#.#.#.
.##..###.#
..#...##..
..##....##
......#...
.####.###.
EX

ex4 = <<-EX
.#..#..###
####.###.#
....###.#.
..###.##.#
##.##.#.#.
....###..#
..#.#..#.#
#..#.#.###
.##...##.#
.....#.#..
EX

ex5 = <<-EX
.#..##.###...#######
##.############..##.
.#.######.########.#
.###.#######.####.#.
#####.##.#.##.###.##
..#####..#.#########
####################
#.####....###.#.#.##
##.#################
#####.##.###..####..
..######..##.#######
####.##.####...##..#
.#####..#.######.###
##...#.##########...
#.##########.#######
.####.#.###.###.#.##
....##.##.###..#####
.#.#.###########.###
#.#.#.#####.####.###
###.##.####.##.#..##
EX

ex6 = <<-EX
.#.
###
.#.
EX

part 1
with :best_observer
try ex1, [[3,4], 8]
try ex2, [[5,8], 33]
try ex3, [[1,2], 35]
try ex4, [[6,3], 41]
try ex5, [[11,13], 210]
try puzzle_input

part 2
with :vaporizations
try ex6, [[1,1], [[1,0], [2,1], [1,2], [0,1]]]
try ex5, [[11,12], [12,1], [12,2]] do |station, zapped|
  zapped.first(3)
end
try ex5, [8,2] do |station, zapped|
  zapped[200 - 1]
end
try puzzle_input do |station, zapped|
  p = zapped[200 - 1]
  p[0] * 100 + p[1]
end
