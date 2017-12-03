require_relative "../toolkit"

def spiral_distance(n)
  radius = 1
  radius +=2 while n > radius*radius
  dist = (radius - 1) / 2
  centers = ((radius * radius ) - dist).step(by: -dist * 2).take(4)
  nearest = centers.map { |c| (n - c).abs }
  nearest.min + dist
end

1.upto(26) do |n|
  puts "#{n} : #{spiral_distance n}"
end

def solution(input)
  spiral_distance input.to_i
end

part 1
with :solution

try "1", 0
try "12", 3
try "23", 2
try "1024", 31
try puzzle_input
