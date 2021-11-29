require_relative "../toolkit"

def draw(points)
  xs = points.map { |p| p[0] }
  ys = points.map { |p| p[1] }

  to_draw = Set.new
  points.each do |x, y, _, _|
    to_draw << [x, y]
  end

  (ys.min - 1).upto(ys.max + 1) do |y|
    (xs.min - 1).upto(xs.max + 1) do |x|
      if to_draw.include?([x, y])
        print "#"
      else
        print " "
      end
    end
    puts
  end

  nil
end

def part1(input)
  points = input.lines.map do |line|
    line.scan(/-?\d+/).map(&:to_i)
  end

  xs = points.map { |p| p[0] }
  ys = points.map { |p| p[1] }
  area = (xs.max - xs.min) * (ys.max - ys.min)

  bar = progress_bar
  t = 0
  loop do

    # xs = points.map { |p| p[0] }
    # ys = points.map { |p| p[1] }
    # area = (xs.max - xs.min) * (ys.max - ys.min)

    # by_x = points.group_by { |p| p[0] }
    # break if by_x.any? do |x, group|
    #   diffs = group.map { |p| p[1] }.sort.each_cons(2).map { |a, b| b - a }
    #   diffs.each_cons(6).any? { |slice| slice == [1, 1, 1, 1, 1, 1] }
    # end
    # by_x = points.group_by { |p| p[0] }
    # break if by_x.any? do |y, group|
    #   counts = group.map { |p| p[1] }.sort.each_cons(2).map { |a, b| b - a }.tally
    #   counts.fetch(1, 0) >= 5
    # end

    next_points = points.map do |x, y, dx, dy|
      [x + dx, y + dy, dx, dy]
    end

    xs = next_points.map { |p| p[0] }
    ys = next_points.map { |p| p[1] }
    next_area = (xs.max - xs.min) * (ys.max - ys.min)
    break if next_area > area

    area = next_area
    points = next_points
    t += 1

    bar.advance
  end
  bar.finish

  draw points
  t
end

# def part2(input)

# end

ex1 = <<-EX
position=< 9,  1> velocity=< 0,  2>
position=< 7,  0> velocity=<-1,  0>
position=< 3, -2> velocity=<-1,  1>
position=< 6, 10> velocity=<-2, -1>
position=< 2, -4> velocity=< 2,  2>
position=<-6, 10> velocity=< 2, -2>
position=< 1,  8> velocity=< 1, -1>
position=< 1,  7> velocity=< 1,  0>
position=<-3, 11> velocity=< 1, -2>
position=< 7,  6> velocity=<-1, -1>
position=<-2,  3> velocity=< 1,  0>
position=<-4,  3> velocity=< 2,  0>
position=<10, -3> velocity=<-1,  1>
position=< 5, 11> velocity=< 1, -2>
position=< 4,  7> velocity=< 0, -1>
position=< 8, -2> velocity=< 0,  1>
position=<15,  0> velocity=<-2,  0>
position=< 1,  6> velocity=< 1,  0>
position=< 8,  9> velocity=< 0, -1>
position=< 3,  3> velocity=<-1,  1>
position=< 0,  5> velocity=< 0, -1>
position=<-2,  2> velocity=< 2,  0>
position=< 5, -2> velocity=< 1,  2>
position=< 1,  4> velocity=< 2,  1>
position=<-2,  7> velocity=< 2, -2>
position=< 3,  6> velocity=<-1, -1>
position=< 5,  0> velocity=< 1,  0>
position=<-6,  0> velocity=< 2,  0>
position=< 5,  9> velocity=< 1, -2>
position=<14,  7> velocity=<-2,  0>
position=<-3,  6> velocity=< 2, -1>
EX

part 1
part 2 # same as part 1
with :part1
debug!
try ex1, expect: 3
no_debug!
try puzzle_input
