require_relative "../toolkit"

def parse_recipes(input)
  # recipes = array of [ingredients, allergens]
  input.split("\n").map do |line|
    ingredients, allergens = line.split("(contains ", 2)
    ingredients = ingredients.chomp.split
    allergens = allergens.sub(")", "").split(", ")
    [ingredients, allergens]
  end
end

def find_allergens(recipes)
  all = recipes.flat_map(&:last).uniq
  found = {}
  count = 0
  while found.length < all.length
    count += 1
    raise "couldn't resolve" if count > recipes.length

    to_find = all - found.keys
    debug "looking for #{to_find}"
    restricted = recipes.map { |i, a| [i.difference(found.values), a] }
    to_find.each do |allergen|
      matched = restricted.select { |_i, a| a.include? allergen }.map(&:first)
      candidates = matched.drop(1).reduce(matched.first, &:intersection)
      debug "  #{allergen}: #{matched} -> #{candidates}"
      found[allergen] = candidates.first if candidates.length == 1
    end
  end

  found
end

def part1(input)
  recipes = parse_recipes(input)
  allergens = find_allergens(recipes)

  not_allergens = recipes.flat_map(&:first).uniq - allergens.values
  recipes.map { |is, _a| is.count { |i| not_allergens.include? i } }.sum
end

def part2(input)
  recipes = parse_recipes(input)
  allergens = find_allergens(recipes)
  allergens.sort_by(&:first).map(&:last).join(",")
end

ex1 = <<-EX
mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
trh fvjkl sbzzf mxmxvkd (contains dairy)
sqjhc fvjkl (contains soy)
sqjhc mxmxvkd sbzzf (contains fish)
EX

part 1
with :part1
debug!
try ex1, expect: 5
no_debug!
try puzzle_input

part 2
with :part2
try ex1, expect: "mxmxvkd,sqjhc,fvjkl"
try puzzle_input
