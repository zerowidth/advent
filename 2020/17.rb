require_relative "../toolkit"

# Sparse set of active nodes
class Conway
  def initialize
    @active = Set.new
  end

  def iterate(&rules)
    next_state = self.class.new

    potential = @active.dup
    @active.each do |coords|
      neighbors_of(*coords).each { |n| potential << n }
    end

    potential.each do |coords|
      active_neighbors = neighbors_of(*coords).select { |n| get(*n) }.count
      if rules.call(coords, get(*coords), active_neighbors)
        next_state.set(*coords)
      else
        next_state.delete(*coords)
      end
    end

    next_state
  end

  include Enumerable
  def each(&block)
    @active.each(&block)
  end

  def length
    @active.length
  end

  def neighbors_of(*coords)
    offsets.map do |off|
      coords.zip(off).map(&:sum)
    end
  end

  def set(*coords)
    @active << coords
  end

  def get(*coords)
    @active.member? coords
  end

  def delete(*coords)
    @active.delete coords
  end

  def offsets
    @offsets ||= [-1, 0, 1].repeated_permutation(@active.first.length).reject { |o| o.all?(&:zero?) }
  end

  DIMENSIONS = %w[x y z w]

  def to_s
    return "empty" if @active.empty?
    return unless $debug

    dimensions = (0...@active.first.length).to_a

    min_by_dimension = dimensions.map do |dim|
      @active.map { |p| p[dim] }.min
    end
    max_by_dimension = dimensions.map do |dim|
      @active.map { |p| p[dim] }.max
    end

    higher_dimensions = dimensions.drop(2).map do |dim|
      min_by_dimension[dim].upto(max_by_dimension[dim]).to_a
    end

    s = ""
    s << "dimensions #{dimensions}\n"
    if higher_dimensions.length > 1
      higher_dimensions = higher_dimensions.take(1).first.product(*higher_dimensions.drop(1))
    end
    s << "higher: #{higher_dimensions}\n"

    higher_dimensions.each do |higher|
      s << higher.map.with_index { |d, i| "#{DIMENSIONS[i]}=#{d}" }.join(", ") << "\n"
      min_by_dimension[1].upto(max_by_dimension[1]) do |y|
        min_by_dimension[0].upto(max_by_dimension[0]).each do |x|
          s << (get(x, y, *higher) ? "▓▓" : "░░")
        end
        s << "\n"
      end
    end

    s
  end
end

def iterate(input, dimensions:)
  cells = Conway.new
  dims = [0] * (dimensions - 2)
  input.lines.each.with_index do |line, row|
    line.strip.chars.each.with_index do |char, col|
      cells.set(col, row, *dims) if char == "#"
    end
  end

  debug "initial state:"
  debug cells

  alive_if = lambda do |_coords, set, active_neighbors|
    if set
      [2, 3].include? active_neighbors
    else
      active_neighbors == 3
    end
  end

  6.times do |cycle|
    cells = cells.iterate(&alive_if)

    if cycle == 1
      debug "after cycle 1"
      debug
      debug cells
    end
  end

  cells.length
end

ex1 = <<-EX
.#.
..#
###
EX

part 1
with :iterate, dimensions: 3
debug!
try ex1, expect: 112
no_debug!
try puzzle_input

part 2
with :iterate, dimensions: 4
debug!
try ex1, expect: 848
no_debug!
try puzzle_input
