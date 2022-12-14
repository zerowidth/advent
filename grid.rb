class Grid
  class Config
    def initialize
      @infinite = false
    end

    def infinite?
      @infinite
    end

    def infinite
      @infinite = true
    end

    def bounded
      @infinite = false
    end
  end

  attr_reader :config, :values

  def initialize(rows = [])
    @config = Config.new
    yield @config if block_given?
    @values = {}
    rows.each.with_index do |row, y|
      row.each.with_index do |v, x|
        set(x, y, v)
      end
    end
  end

  def get(*coords)
    values[coords]
  end

  alias [] get

  def set(*coords, value)
    values[coords] = value
  end

  alias []= set

  include Enumerable
  def each
    xmin = values.keys.map(&:first).min
    xmax = values.keys.map(&:first).max
    ymin = values.keys.map(&:last).min
    ymax = values.keys.map(&:last).max
    if block_given?
      ymin.upto(ymax) do |y|
        xmin.upto(xmax) do |x|
          yield [x, y, get(x, y)]
        end
      end
    else
      Enumerator.new do |enum|
        ymin.upto(ymax) do |y|
          xmin.upto(xmax) do |x|
            enum << [x, y, get(x, y)]
          end
        end
      end
    end
  end

  def neighbors(x, y, diagonal: false)
    ns =
      [
        [x + 1, y],
        [x - 1, y],
        [x, y + 1],
        [x, y - 1],
      ]
    if diagonal
      ns += [
        [x + 1, y + 1],
        [x - 1, y + 1],
        [x + 1, y - 1],
        [x - 1, y - 1],
      ]
    end
    ns.select do |nx, ny|
      config.unbounded? || (nx >= 0 && nx < width && ny >= 0 && ny < height)
    end
  end

  def width
    if config.unbounded?
      xs = values.keys.map(&:first)
      xs.max - xs.min
    else
      @width ||= begin
          xs = values.keys.map(&:first)
          xs.max - xs.min
        end
    end
  end

  def height
    if config.unbounded?
      ys = values.keys.map(&:last)
      ys.max - ys.min
    else
      @height ||= begin
          ys = values.keys.map(&:last)
          ys.max - ys.min
        end
    end
  end

  def to_s(pad: 1)
    s = ""
    keys = values.keys
    xmin = keys.map(&:first).min
    xmax = keys.map(&:first).max
    ymin = keys.map(&:last).min
    ymax = keys.map(&:last).max

    size = values.values.map(&:to_s).map(&:length).max + pad

    ymin.upto(ymax) do |y|
      xmin.upto(xmax) do |x|
        key = [x, y]
        v = values[key]
        if !v.nil?
          s << v.to_s.rjust(size)
        else
          s << " " * size
        end
      end
      s << "\n"
    end
    s
  end
end
