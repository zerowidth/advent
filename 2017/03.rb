require_relative "../toolkit"

def spiral_distance(n)
  radius = 1
  radius +=2 while n > radius*radius
  dist = (radius - 1) / 2
  centers = ((radius * radius ) - dist).step(by: -dist * 2).take(4)
  nearest = centers.map { |c| (n - c).abs }
  nearest.min + dist
end

1.upto(26) do |n|
  puts "#{n} : #{spiral_distance n}"
end

def solution(input)
  spiral_distance input.to_i
end

part 1
with :solution

try "1", 0
try "12", 3
try "23", 2
try "1024", 31
part_one_max = try puzzle_input

part 2

NEXT_DIR = {
  up: :left,
  left: :down,
  down: :right,
  right: :up,
}

def generate_spiral(entries, &block)
  x = 0
  y = 0
  r = 1
  dir = :up
  spiral = {}

  1.upto(entries) do |n|
    spiral[ [x, y] ] = yield spiral, n, x, y
    if n == r * r
      x += 1
      r += 2
      dir = :up
    else
      dir = NEXT_DIR[dir] if (n - 1) % ((r - 1)) == 0
      case dir
      when :up
        y -= 1
      when :left
        x -= 1
      when :down
        y += 1
      when :right
        x += 1
      end
    end
  end

  spiral
end

def print_spiral(spiral)
  xmin = spiral.keys.map(&:first).min
  xmax = spiral.keys.map(&:first).max
  ymin = spiral.keys.map(&:last).min
  ymax = spiral.keys.map(&:last).max

  w = xmax - xmin + 1
  h = ymax - ymin + 1
  size = spiral.values.map(&:to_s).map(&:length).max + 1

  ymin.upto(ymax) do |y|
    xmin.upto(xmax) do |x|
      if v = spiral[ [x,y] ]
        print v.to_s.rjust(size)
      else
        print " " * size
      end
    end
    puts
  end

end

# s = generate_spiral(100) { |h, n, x, y| n }
# print_spiral s

def adjacent_sum(grid, cx, cy)
  sum = 0
  (cx-1).upto(cx+1) do |x|
    (cy-1).upto(cy+1) do |y|
      next if x == cx && y == cy
      sum += grid.fetch([x,y], 0)
    end
  end
  sum
end

s = generate_spiral(23) do |h, n, x, y|
  if x == 0 && y == 0
    1
  else
    adjacent_sum(h, x, y)
  end
end
print_spiral s

max = puzzle_input.to_i
generate_spiral(max) do |h, n, x, y|
  if x == 0 && y == 0
    1
  else
    sum = adjacent_sum(h, x, y)
    if sum > max
      puts "next adjacent sum after #{max}: #{sum}"
      exit
    end
    sum
  end
end
