require_relative "../toolkit"

def closest_intersection(input)
  wires = input.split.map(&:strip).map { |line| line.strip.split(",") }
  grid = Grid.new

  intersections = Set.new
  wires.each.with_index do |instructions, wire|
    x = y = 0
    instructions.each do |instruction|
      dx = 0
      dy = 0
      case instruction[0]
      when "R"
        dx = 1
      when "L"
        dx = -1
      when "U"
        dy = 1
      when "D"
        dy = -1
      end

      instruction[1..].to_i.times do
        x += dx
        y += dy
        if grid.at(x, y) && wire > grid.at(x, y)
          intersections.add [x, y]
        end
        grid.set(x, y, wire)
      end
    end
  end

  intersections.map { |is| is.map(&:abs).sum }.min
end

def take_two(input)
  wires = input.split.map(&:strip).map { |line| line.strip.split(",") }
  intersections = wires.map_with(:map_wire).map(&:points_set).reduce(&:&)
  intersections.map { |is| is.map(&:abs).sum }.min
end

def nearest_by_wire(input)
  wires = input.split.map(&:strip).map { |line| line.strip.split(",") }
  grids = wires.map_with(:map_wire)
  intersections = grids.map(&:points_set).reduce(&:&)
  intersections.map { |x, y| grids.map { |g| g.at(x, y) } }.map(&:sum).min
end

def map_wire(instructions)
  grid = Grid.new
  x = y = 0
  step = 0
  instructions.each do |instruction|
    dx = 0
    dy = 0
    case instruction[0]
    when "R"
      dx = 1
    when "L"
      dx = -1
    when "U"
      dy = 1
    when "D"
      dy = -1
    end
    instruction[1..].to_i.times do
      x += dx
      y += dy
      step += 1
      grid.set(x, y, step) unless grid.at(x, y)
    end
  end
  grid
end

ex1 = <<-EX
R8,U5,L5,D3
U7,R6,D4,L4
EX

ex2 = <<-EX
R75,D30,R83,U83,L12,D49,R71,U7,L72
U62,R66,U55,R34,D71,R55,D58,R83
EX

ex3 = <<-EX
R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
U98,R91,D20,R16,D67,R40,U7,R15,U6,R7
EX

part 1
with :take_two
try ex1, 6
try ex2, 159
try ex3, 135
try puzzle_input

part 2
with :nearest_by_wire
try ex1, 30
try ex2, 610
try ex3, 410
try puzzle_input
