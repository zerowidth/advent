require_relative "../toolkit"

DIRS = [
  [0, 1],
  [1, 0],
  [0, -1],
  [-1, 0]
]

def part1(input)
  pos = [0, 0]
  dir = 0
  input.split(", ").each do |step|
    turn = step[0]
    dist = step[1..].to_i
    dir = (dir + (turn == "R" ? 1 : -1)) % 4
    change = DIRS[dir].map { |v| v * dist }
    pos = pos.zip(change).map(&:sum)
  end
  pos.map(&:abs).sum
end

def part2(input)
  pos = [0, 0]
  visited = Set.new([pos])
  dir = 0
  input.split(", ").each do |step|
    turn = step[0]
    dist = step[1..].to_i
    dir = (dir + (turn == "R" ? 1 : -1)) % 4
    debug step
    dist.times do
      pos = pos.zip(DIRS[dir]).map(&:sum)
      debug "  #{pos}"
      return pos.map(&:abs).sum if visited.include?(pos)
      visited << pos
    end
  end
  "no duplicate"
end

ex1 = <<EX
R2, L3
EX

ex2 = <<EX
R5, L5, R5, R3
EX

ex3 = <<EX
R8, R4, R4, R8
EX

part 1
with :part1
debug!
try ex1, 5
try ex2, 12
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex3, 4
no_debug!
try puzzle_input
