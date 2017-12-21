require_relative "../toolkit"

class Particle
  def initialize(p, v, a)
    @p = p
    @v = v
    @a = a
    @distances = []
  end

  def step
    @v[0] += @a[0]
    @v[1] += @a[1]
    @v[2] += @a[2]
    @p[0] += @v[0]
    @p[1] += @v[1]
    @p[2] += @v[2]
    @distances << distance
  end

  def distance
    @p.map(&:abs).sum
  end

  def position
    @p
  end

  def distances
    @distances
  end
end

def solution(input)
  particles = input.lines.map do |line|
    p, v, a = *line.scan(/<(-?\d+,-?\d+,-?\d+)>/).map { |vec| vec.first.split(",").map(&:to_i) }
    raise "what? #{[p, v, a].inspect}" if [p, v, a].any? {|vec| vec.length != 3 }
    Particle.new p, v, a
  end

  nearest = []
  10.times do
    100.times do
      particles.map(&:step)
    end
    p = particles.min_by(&:distance)
    nearest << particles.index(p)
  end

  nearest
end

example = <<-EX
p=<3,0,0>, v=<2,0,0>, a=<-1,0,0>
p=<4,0,0>, v=<0,0,0>, a=<-2,0,0>
EX

part 1
with(:solution)
try example, 0
try puzzle_input

def collisions(input)
  particles = input.lines.map do |line|
    p, v, a = *line.scan(/<(-?\d+,-?\d+,-?\d+)>/).map { |vec| vec.first.split(",").map(&:to_i) }
    raise "what? #{[p, v, a].inspect}" if [p, v, a].any? {|vec| vec.length != 3 }
    Particle.new p, v, a
  end


  remaining = []
  10.times do
    100.times do
      particles.map(&:step)
      grouped = particles.group_by(&:position)
      grouped.select do |pos, group|
        if group.length > 1
          group.each { |particle| particles.delete particle }
        end
      end
      remaining << particles.count
    end
  end

  remaining

end

example = <<-EX
p=<-6,0,0>, v=<3,0,0>, a=<0,0,0>
p=<-4,0,0>, v=<2,0,0>, a=<0,0,0>
p=<-2,0,0>, v=<1,0,0>, a=<0,0,0>
p=<3,0,0>, v=<-1,0,0>, a=<0,0,0>
EX

part 2
with(:collisions)
try example, 1
try puzzle_input
