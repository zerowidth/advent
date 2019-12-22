# infinite grid, using vector coords
class Vec
  attr_reader :x, :y

  def self.[](x, y)
    new(x, y)
  end

  def initialize(x, y)
    @x = x
    @y = y
  end

  def +(other)
    Vec[x + other.x, y + other.y]
  end

  def -(other)
    Vec[x - other.x, y - other.y]
  end

  include Comparable
  def <=>(other)
    (x <=> other.x) == 0 ? (y <=> other.y) : (x <=> other.x)
  end

  # for Hash usage:
  alias eql? ==
  def hash
    x.hash ^ y.hash # XOR
  end

  def to_a
    [x, y]
  end

  def to_s
    "[#{x},#{y}]"
  end
  alias inspect to_s
end

class Grid

  def initialize(&value_block)
    @points = {}
    @value_block = value_block
  end

  def get(p)
    if @points.key? p
      @points[p]
    elsif @value_block
      @points[p] = @value_block.call(p)
    end
  end
  alias [] get

  def set(p, value)
    @points[p] = value
  end
  alias []= set

  def value_at?(p)
    @points.key? p
  end

  def locate(value=nil, &filter)
    points = filter ? select(&filter) : select { |p, v| v == value }
    points.map { |p, v| p }
  end

  def width
    xs = @points.keys.map(&:x)
    xs.max - xs.min
  end

  def height
    ys = @points.keys.map(&:y)
    ys.max - ys.min
  end

  def adjacent_points(pos, diagonal: true)
    vs = []
    (pos.x-1).upto(pos.x+1) do |x|
      (pos.y-1).upto(pos.y+1) do |y|
        next if x == pos.x && y == pos.y
        next if !diagonal && x != pos.x && y != pos.y
        vs << Vec[x,y]
      end
    end
    vs
  end

  def adjacent_values(pos, diagonal: true)
    vs = []
    (pos.x-1).upto(pos.x+1) do |x|
      (pos.y-1).upto(pos.y+1) do |y|
        next if x == pos.x && y == pos.y
          next if !diagonal && x != pos.x && y != pos.y
        vs << get(Vec[x, y])
      end
    end
    vs
  end

  include Enumerable
  def each
    keys = @points.keys
    xs = keys.map(&:x)
    ys = keys.map(&:y)
    ys.min.upto(ys.max) do |y|
      xs.min.upto(xs.max) do |x|
        p = Vec[x, y]
        yield [p, @points[p]]
      end
    end
  end

  def points_set
    Set.new @points.keys
  end

  def to_s(pad: 0)
    size = @points.values.map(&:to_s).map(&:length).max + pad

    keys = @points.keys
    xs = keys.map(&:x)
    ys = keys.map(&:y)
    s = ""
    ys.min.upto(ys.max) do |y|
      xs.min.upto(xs.max) do |x|
        p = Vec[x, y]
        v = @points[p]
        if v == nil
          s << " " * size
        else
          s << v.to_s.rjust(size)
        end
      end
      s << "\n"
    end
    s
  end
end


