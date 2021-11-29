require_relative "../toolkit"

def manhattan(ax, ay, bx, by)
  (ax - bx).abs + (ay - by).abs
end

# for every point between min/max x and y, find the closest point
# find the convex hull
# measure the area for each point, disregarding those on the hull
# alternately: expand the range of points to +/- 1, and disregard all points
# touching that region since they're infinite.
def part1(input)
  points = input.lines.map(&:numbers)

  xs = points.map(&:first)
  ys = points.map(&:last)

  bar = progress_bar(total: ((xs.max - xs.min + 2) * (ys.max - ys.min + 2)))
  areas = Hash.new(0)
  ignored = Set.new
  (xs.min - 1).upto(xs.max + 1) do |x|
    (ys.min - 1).upto(ys.max + 1) do |y|
      distances = points.map.with_index do |(px, py), i|
        [i, manhattan(x, y, px, py)]
      end
      distances = distances.group_by(&:last)

      # array of [[point, distance], ...]
      nearest = distances[distances.keys.min]
      if nearest.length == 1
        areas[nearest.first[0]] += 1 

        if x == xs.min - 1 || x == xs.max + 1 || y == ys.min - 1 || y == ys.max + 1
          # ignore this point, it's on the edge and therefore infinite
          ignored << nearest.first[0]
        end
      end

      bar.advance
    end
  end
  bar.finish

  debug ignored
  debug areas
  areas.except(*ignored.to_a).values.max
end

def part2(input, region:)
  points = input.lines.map(&:numbers)

  xs = points.map(&:first)
  ys = points.map(&:last)
  bar = progress_bar(total: (xs.max - xs.min) * (ys.max - ys.min))

  count = 0
  xs.min.upto(xs.max) do |x|
    ys.min.upto(ys.max) do |y|
      total = 0
      points.each do |px, py|
        total += manhattan(x, y, px, py)
        break if total >= region
      end
      count += 1 if total < region
      bar.advance
    end
  end

  bar.finish

  count
end

ex1 = <<-EX
1, 1
1, 6
8, 3
3, 4
5, 5
8, 9
EX

part 1
with :part1
debug!
try ex1, expect: 17
no_debug!
try puzzle_input

part 2
with :part2, region: 32
debug!
try ex1, expect: 16
with :part2, region: 10_000
no_debug!
try puzzle_input
