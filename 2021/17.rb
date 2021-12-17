require_relative "../toolkit"

class Target
  attr_reader :xmin, :xmax, :ymin, :ymax
  def initialize(xmin, xmax, ymin, ymax)
    @xmin, @xmax, @ymin, @ymax = xmin, xmax, ymin, ymax
  end

  def hit?(x, y)
    x >= xmin && x <= xmax && y >= ymin && y <= ymax
  end

  def short?(x)
    x < xmin
  end

  def past?(x, y)
    y < ymin || x > xmax
  end
end

def hits(input)
  area = input.signed_numbers
  target = Target.new(*area)

  max_vx = target.xmax
  min_vy = target.ymin

  hits = []
  max_vx.downto(0) do |vx|
    has_hit = false
    min_vy.upto(1000) do |vy|
      hit, height = fire(vx, vy, target)
      if hit
        debug "#{vx}, #{vy}: hit #{hit} height #{height}"
        hits << height
      end
    end
  end
  hits
end

def part1(input)
  hits(input).max
end

def part2(input)
  hits(input).count
end

def fire(vx, vy, target)
  x = y = 0
  max_y = 0
  until target.hit?(x, y) || (vx == 0 && target.short?(x)) || target.past?(x, y)
    # debug "  #{x} #{y}"
    x += vx
    y += vy
    vx -= 1 if vx > 0
    vy -= 1
    max_y = y if y > max_y
  end

  [target.hit?(x, y), max_y]
end

ex1 = <<EX
target area: x=20..30, y=-10..-5
EX

part 1
with :part1
debug!
try ex1, 45
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, 112
no_debug!
try puzzle_input
