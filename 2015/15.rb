require_relative "../toolkit"

Ingredient = Struct.new(:name, :capacity, :durability, :flavor, :texture, :calories)

def cookies(input, tsp)
  ingredients = input.lines.map do |line|
    name, properties = line.split(":")
    i = Ingredient.new name
    properties.split(", ").each do |pair|
      k, v = pair.split(" ")
      i.send(:"#{k}=", v.to_i)
    end
    i
  end


end

example = <<-EX
Butterscotch: capacity -1, durability -2, flavor 6, texture 3, calories 8
Cinnamon: capacity 2, durability 3, flavor -2, texture -1, calories 3
EX

part 1
with :cookies, 100

try example, 62842880
# try puzzle_input
