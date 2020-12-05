require_relative "../toolkit"

ex1 = <<-EX
..##.......
#...#...#..
.#....#..#.
..#.#...#.#
.#...##..#.
..#.##.....
.#.#.#....#
.#........#
#.##...#...
#...##....#
.#..#...#.#
EX

def count_trees(rows, right, down)
  puts "counting: #{right} #{down}"
  width = rows.first.size
  height = rows.size

  x, y = 0, 0
  count = 0
  while y < (height - 1)
    x = (x + right) % width
    y = (y + down)
    count += 1 if rows[y] && rows[y][x] == "#"
  end

  count
end

def part1(input, right, down)
  rows = input.each_line.map { |line| line.strip.each_char.to_a }
  count_trees rows, right, down
end

def part2(input, pairs)
  rows = input.each_line.map { |line| line.strip.each_char.to_a }
  pairs.map { |right, down| count_trees rows, right, down }.reduce(1, &:*)
end

part 1
with :part1, 3, 1
try ex1, expect: 7
try puzzle_input

part 2
with :part2, [[1, 1], [3, 1], [5, 1], [7, 1], [1, 2]]
try ex1, expect: 336
try puzzle_input
