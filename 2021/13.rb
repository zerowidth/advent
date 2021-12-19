require_relative "../toolkit"

def part1(input)
  dots, folds = input.sections
  dots = dots.lines.map(&:numbers)
  folds = folds.lines.map do |line|
    line.scan(/fold along (.)=(\d+)/)
    [$1, $2.to_i]
  end

  debug "dots: #{dots}"

  folds = folds.take(1)
  folds.each do |f|
    dim, pos = *f
    if dim == "x"
      dots = dots.map do |x, y|
        x = (2 * pos) - x if x > pos
        [x, y]
      end
    else
      dots = dots.map do |x, y|
        y = (2 * pos) - y if y > pos
        [x, y]
      end
    end
  end

  debug "dots: #{dots}"

  dots.uniq.length
end

def part2(input)
  dots, folds = input.sections
  dots = dots.lines.map(&:numbers)
  folds = folds.lines.map do |line|
    line.scan(/fold along (.)=(\d+)/)
    [$1, $2.to_i]
  end

  debug "dots: #{dots}"

  folds.each do |f|
    dim, pos = *f
    if dim == "x"
      dots = dots.map do |x, y|
        x = pos - (x - pos) if x > pos
        [x, y]
      end
    else
      dots = dots.map do |x, y|
        y = pos - (y - pos) if y > pos
        [x, y]
      end
    end
    dots = dots.uniq
  end

  rows = dots.max_by(&:last).last
  cols = dots.max_by(&:first).first

  0.upto(rows) do |row|
    0.upto(cols) do |col|
      print dots.include?([col, row]) ? "##" : "  "
    end
    puts
  end
  puts

  nil
end

ex1 = <<EX
6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5
EX

part 1
with :part1
debug!
try ex1, 17
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, nil
no_debug!
try puzzle_input
