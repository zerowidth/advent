require_relative "../toolkit"

Ingredient = Struct.new(:name, :capacity, :durability, :flavor, :texture, :calories)

def cookies(input, count, &block)
  ingredients = {}
  input.lines.each do |line|
    name, properties = line.split(":")
    ingredient = {}
    values = properties.split(", ").map do |pair|
      k, v = pair.split(" ")
      [k, v.to_i]
    end

    ingredients[name] = Hash[values]
  end

  recipes = ingredients.keys.repeated_combination(count).map { |is| is.tally_by(&:itself) }
  recipes.map do |recipe|
    [recipe, score(ingredients, recipe, &block)]
  end
end

def score(ingredients, recipe, &block)
  if block_given?
    return 0 unless block.call(ingredients, recipe)
  end

  %w[capacity durability flavor texture].map do |property|
    sub_score = recipe.map do |ingredient, count|
      ingredients[ingredient][property] * count
    end.sum

    return 0 if sub_score.negative?

    sub_score
  end.inject(&:*)
end

def best_cookie(input, count)
  best = cookies(input, count).max_by(&:last)
  puts "best: #{best.first.inspect}"
  best.last
end

def cookie_calories(input, count, calories)
  best = cookies(input, count) do |ingredients, recipe|
    recipe.map do |ingredient, n|
      ingredients[ingredient]["calories"] * n
    end.sum == calories
  end.max_by(&:last)
  puts "best: #{best.first.inspect}"
  best.last
end

example = <<-EX
Butterscotch: capacity -1, durability -2, flavor 6, texture 3, calories 8
Cinnamon: capacity 2, durability 3, flavor -2, texture -1, calories 3
EX

part 1
with :best_cookie, 100

try example, 62842880
try puzzle_input

part 2
with :cookie_calories, 100, 500
try example, 57600000
try puzzle_input
