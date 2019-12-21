require_relative "../toolkit"

class Moon
  attr_reader :position, :velocity
  def initialize(position)
    @position = position
    @velocity = [0,0,0]
  end

  def move!
    @position = @position.zip(@velocity).map(&:sum)
  end

  def pulled_by(other)
    @position.zip(other.position).each.with_index do |diff, i|
      if diff[0] > diff[1]
        @velocity[i] -= 1
      elsif diff[0] < diff[1]
        @velocity[i] += 1
      end
    end
  end

  def energy
    @position.map(&:abs).sum * @velocity.map(&:abs).sum
  end

  def state
    @position + @velocity
  end

  include Comparable
  def <=>(other)
    a = (@position <=> other.position)
    a == 0 ? (@velocity <=> other.velocity) : a
  end

  def inspect
    "pos=#{position} vel=#{velocity}"
  end
end

class Axis
  attr_reader :steps
  attr_reader :ps, :vs

  def initialize(positions)
    @ps = positions
    @vs = Array.new(positions.length, 0)
    @steps = 0
  end

  def step(n=1)
    n.times do
      @steps += 1
      # apply gravity
      @ps.each.with_index do |p, i|
        @vs[i] += @ps.map { |q| q <=> p }.sum
      end
      # apply velocity
      @vs.each.with_index do |v, i|
        @ps[i] += v
      end
    end
  end

  include Comparable
  def <=>(other)
    a = (ps <=> other.ps)
    a == 0 ? (vs <=> other.vs) : a
  end
end

class Orbits
  attr_reader :moons
  attr_reader :steps

  def initialize(input, debug)
    @moons = input.split("\n").map do |line|
      Moon.new line.scan(/(-?\d+)/).flatten.map(&:to_i)
    end
    @debug = debug
    @steps = 0
  end

  def step(times=1)
    times.times do
      @steps += 1
      # apply gravity to each pair of moons
      @moons.combination(2) do |a, b|
        a.pulled_by b
        b.pulled_by a
      end

      # move moons by their velocity
      @moons.each(&:move!)

      if @debug
        STDERR.puts "after step #{@steps}:"
        @moons.each { |m| STDERR.puts "  #{m.inspect}" }
      end
    end
  end

  def total_energy
    @moons.map(&:energy).sum
  end

  include Comparable
  def <=>(other)
    @moons <=> other.moons
  end
end

def positions(input, steps, debug)
  orbits = Orbits.new input, debug
  orbits.step(steps)
  orbits
end

def repeats(input)
  tortoise = Orbits.new input, false
  hare = Orbits.new input, false
  loop do
    tortoise.step(1)
    hare.step(2)
    break if tortoise == hare
  end
  tortoise.steps
end

def faster(input)
  moons = Orbits.new(input, false).moons
  x = moons.map { |m| m.position[0] }
  y = moons.map { |m| m.position[1] }
  z = moons.map { |m| m.position[2] }
  [steps(x), steps(y), steps(z)].reduce 1, &:lcm
end

def steps(positions)
  tortoise = Axis.new positions.dup
  tortoise.step 1
  hare = Axis.new positions.dup
  hare.step 2
  while tortoise != hare do
    tortoise.step
    hare.step 2
  end
  tortoise.steps
end

ex1 = <<-EX
<x=-1, y=0, z=2>
<x=2, y=-10, z=-7>
<x=4, y=-8, z=8>
<x=3, y=5, z=-1>
EX

ex2 = <<-EX
<x=-8, y=-10, z=0>
<x=5, y=5, z=10>
<x=2, y=-7, z=3>
<x=9, y=-8, z=-3>
EX

ex3 = <<-EX
EX

part 1
with :positions, 10, false
try ex1, 179 do |orbits|
  orbits.total_energy
end
with :positions, 100, false
try ex2, 1940 do |orbits|
  orbits.total_energy
end
with :positions, 1000, false
try puzzle_input do |orbits|
  orbits.total_energy
end

part 2
with :repeats
try ex1, 2772
with :faster
try ex1, 2772
# with :repeats, 1_000_000
try ex2, 4686774924
try puzzle_input
