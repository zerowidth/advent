require_relative "../toolkit"
require_relative "../2019/grid"

ex1 = <<-EX
F10
N3
F7
R90
F11
EX

DIRS = [
  Vec[1, 0], # east
  Vec[0, 1], # south
  Vec[-1, 0], # west
  Vec[0, -1], # north
]

def debug=(val)
  @debug = val
end

def debug(msg)
  if @debug
    puts msg
  end
end

def part1(input)
  pos = Vec[0, 0]
  dir = 0 # east

  input.each_line.map(&:strip).map do |line|
    match = line.scan(/([A-Z])(\d+)/).first
    instruction = match[0]
    amount = match[1].to_i
    case instruction
    when "N"
      pos += (DIRS[3] * amount)
      debug "north #{amount} : #{pos} #{dir}"
    when "S"
      pos += DIRS[1] * amount
      debug "south #{amount} : #{pos} #{dir}"
    when "E"
      pos += DIRS[0] * amount
      debug "east #{amount} : #{pos} #{dir}"
    when "W"
      pos += DIRS[2] * amount
      debug "west #{amount} : #{pos} #{dir}"
    when "R"
      dir = (dir + (amount / 90)) % 4
      debug "right #{amount} : #{pos} #{dir}"
    when "L"
      dir = (dir + (4 - (amount / 90))) % 4
      debug "left #{amount} : #{pos} #{dir}"
    when "F"
      pos += DIRS[dir] * amount
      debug "forward #{amount} : #{pos} #{dir}"
    else
      raise "wtf: #{instruction.inspect}"
    end
  end

  pos.to_a.map(&:abs).sum
end

def part2(input)
  ship = Vec[0, 0]
  # dir = 0 # east
  waypoint = Vec[10, -1]

  input.each_line.map(&:strip).map do |line|
    match = line.scan(/([A-Z])(\d+)/).first
    instruction = match[0]
    amount = match[1].to_i
    case instruction
    when "N"
      waypoint += (DIRS[3] * amount)
      debug "north #{amount} : #{ship} #{waypoint}"
    when "S"
      waypoint += DIRS[1] * amount
      debug "south #{amount} : #{ship} #{waypoint}"
    when "E"
      waypoint += DIRS[0] * amount
      debug "east #{amount} : #{ship} #{waypoint}"
    when "W"
      waypoint += DIRS[2] * amount
      debug "west #{amount} : #{ship} #{waypoint}"
    when "R"
      (amount / 90).times do
        waypoint = Vec[-waypoint.y, waypoint.x]
      end
      debug "right #{amount} : #{ship} #{waypoint}"
    when "L"
      (amount / 90).times do
        waypoint = Vec[waypoint.y, -waypoint.x]
      end
      debug "left #{amount} : #{ship} #{waypoint}"
    when "F"
      ship += waypoint * amount
      debug "forward #{amount} : #{ship} #{waypoint}"
    else
      raise "wtf: #{instruction.inspect}"
    end
  end

  ship.to_a.map(&:abs).sum
end

part 1
with :part1
try ex1, expect: 25
try puzzle_input

part 2
with :part2
try ex1, expect: 286
try puzzle_input
