require_relative "../toolkit"

# https://www.redblobgames.com/grids/hexagons/

DIRS = {
  "n" => [0, 1, -1],
  "ne" => [1, 0, -1],
  "se" => [1, -1, 0],
  "s" => [0, -1, 1],
  "sw" => [-1, 0, 1],
  "nw" => [-1, 1, 0],
}

def final_distance(input)
  path = input.split(",").map { |dir| DIRS[dir] }
  pos = path.each_with_object([0,0,0]) { |step, pos| 0.upto(2) {|i| pos[i] += step[i]} }
  pos.map(&:abs).max
end

def max_distance(input)
  path = input.split(",").map { |dir| DIRS[dir] }
  pos = [0, 0, 0]
  steps = path.map do |step|
    0.upto(2) {|i| pos[i] += step[i]}
    pos.dup
  end
  steps.map { |step| step.map(&:abs).max }.max
end

part 1
with(:final_distance)
try "ne,ne,ne", 3
try "ne,ne,sw,sw", 0
try "ne,ne,s,s", 2
try "se,sw,se,sw,sw", 3

try puzzle_input

part 2
with(:max_distance)
try "ne,ne,ne", 3
try "ne,ne,sw,sw", 2
try "ne,ne,s,s", 2
try "se,sw,se,sw,sw", 3

try puzzle_input
