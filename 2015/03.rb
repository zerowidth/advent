require_relative "../toolkit"
require "set"

Santa = Struct.new(:x, :y) do
  def pos
    [x, y]
  end
end

def house_visits(input, santas)
  ss = santas.times.map { Santa.new(0, 0) }
  houses = Set.new
  houses << [0, 0]

  input.each_char do |c|
    santa = ss.first
    case c
    when "^"
      santa.y += 1
    when ">"
      santa.x += 1
    when "v"
      santa.y -= 1
    when "<"
      santa.x -= 1
    end

    houses << santa.pos
    ss = ss.rotate(1)
  end

  houses.size
end

with :house_visits, 1
try ">", 2
try "^>v<", 4
try "^v^v^v^v^v", 2
try puzzle_input

with :house_visits, 2
try "^v", 3
try "^>v<", 3
try "^v^v^v^v^v", 11
try puzzle_input
