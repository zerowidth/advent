require_relative "../toolkit"

def part1(input)
  trees = input.lines_of(:digits)
  visible = []
  trees.length.times { visible << Array.new(trees.length, false) }

  trees.each_with_index do |row, y|
    height = -1
    0.to(row.length - 1).each do |x|
      if row[x] > height
        height = row[x]
        visible[y][x] = true
      end
    end
    height = -1
    (row.length - 1).to(0).each do |x|
      if row[x] > height
        height = row[x]
        visible[y][x] = true
      end
    end
  end
  0.to(trees.length - 1).each do |x|
    height = -1
    0.to(trees.length - 1).each do |y|
      if trees[y][x] > height
        height = trees[y][x]
        visible[y][x] = true
      end
    end
    height = -1
    (trees.length - 1).to(0).each do |y|
      if trees[y][x] > height
        height = trees[y][x]
        visible[y][x] = true
      end
    end
  end
  dpp visible
  visible.flatten.count { |v| v }
end

DIRS = [
  [0, -1],
  [-1, 0],
  [1, 0],
  [0, 1]
]

class Grid
  def initialize(rows)
    @rows = rows
  end

  def [](x, y)
    if x < 0 || y < 0
      return nil
    end
    if x >= @rows.first.length || y >= @rows.length
      return nil
    end
    @rows[y][x]
  end

  def width
    @rows.first.length
  end

  def height
    @rows.length
  end
end

def part2(input)
  trees = Grid.new(input.lines_of(:digits))

  scores = []
  trees.height.times do |y|
    trees.width.times do |x|
      height = trees[x, y]
      distances = []
      DIRS.each do |dx, dy|
        distance = 0
        nx = x + dx
        ny = y + dy
        while trees[nx, ny]
          distance += 1
          break if trees[nx, ny] >= height
          nx += dx
          ny += dy
        end
        distances << distance
      end
      scores << [[x, y], distances]
    end
  end
  dpp scores
  scores.map(&:last).map { |ds| ds.reduce(&:*) }.max
end

ex1 = <<EX
30373
25512
65332
33549
35390
EX

part 1
with :part1
debug!
try ex1, 21
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, 8
no_debug!
try puzzle_input
