require_relative "../toolkit"

ex1 = <<-EX
10 ORE => 10 A
1 ORE => 1 B
7 A, 1 B => 1 C
7 A, 1 C => 1 D
7 A, 1 D => 1 E
7 A, 1 E => 1 FUEL
EX

ex2 = <<-EX
9 ORE => 2 A
8 ORE => 3 B
7 ORE => 5 C
3 A, 4 B => 1 AB
5 B, 7 C => 1 BC
4 C, 1 A => 1 CA
2 AB, 3 BC, 4 CA => 1 FUEL
EX

ex3 = <<-EX
157 ORE => 5 NZVS
165 ORE => 6 DCFZ
44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
179 ORE => 7 PSHF
177 ORE => 5 HKGWZ
7 DCFZ, 7 PSHF => 2 XJWVT
165 ORE => 2 GPVTF
3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
EX

ex4 = <<-EX
2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
17 NVRVD, 3 JNWZP => 8 VPVL
53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
22 VJHF, 37 MNCFX => 5 FWMGM
139 ORE => 4 NVRVD
144 ORE => 7 JNWZP
5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
145 ORE => 6 MNCFX
1 NVRVD => 8 CXFTF
1 VJHF, 6 MNCFX => 4 RFSQX
176 ORE => 6 VJHF
EX

ex5 = <<-EX
171 ORE => 8 CNZTR
7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
114 ORE => 4 BHXH
14 VRPVC => 6 BMBT
6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
5 BMBT => 4 WPTQ
189 ORE => 9 KTJDG
1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
12 VRPVC, 27 CNZTR => 2 XDBXC
15 KTJDG, 12 BHXH => 5 XCVML
3 BHXH, 2 VRPVC => 7 MZWV
121 ORE => 7 VRPVC
7 XCVML => 6 RJRHP
5 BHXH, 4 VRPVC => 5 LTCX
EX

def parse(input)
  recipe = {}
  input.split("\n").each do |line|
    parts = line.scan(/(\d+) (\w+)/).map do |part|
      [part[1], part[0].to_i]
    end
    recipe[parts.last[0]] = [parts.last[1], parts[0..-2]]
  end
  recipe
end

def recipe_rows(input)
  input.split("\n").map do |line|
    parts = line.scan(/(\d+) (\w+)/).map do |part|
      [part[1], part[0].to_i]
    end
  end
end

# class Ingredient
  # attr_reader :name, :amount

  # def initialize(name, amount)
    # @name = name
    # @amount = amount
  # end

  # def hash
    # name.hash
  # end

  # include Comparable
  # def <=>(other)
    # name <=> other.name
  # end

  # def +(other)
    # if other.kind_of?(Integer)
      # Ingredient.new name, amount + other
    # elsif name != other.name
      # raise ArgumentError, "not the same ingredient! #{self} + #{other}"
    # else
      # Ingredient.new name, amount + other.amount
    # end
  # end

  # def *(other)
    # if other.kind_of?(Integer)
      # Ingredient.new name, amount * other
    # elsif name != other.name
      # raise ArgumentError, "not the same ingredient! #{self} * #{other}"
    # else
      # Ingredient.new name, amount * other.amount
    # end
  # end

  # def to_s
    # "#{name}(#{amount})"
  # end
  # alias inspect to_s
# end

def coalesce(ingredients)
  ingredients.group_by(&:first).map do |name, amounts|
    [name, amounts.map(&:last).sum]
  end
end

$nest = 0
def debug(msg)
  puts ".." * $nest + msg if $debug
end

def reduce(recipe, ingredient, amount, max_ore = 0)
  needs = Hash.new(0)
  needs[ingredient] = amount
  supply = Hash.new(0)
  fuel_made = 0

  # count = 0
  loop do
    # count += 1
    # break if count > 10
    debug "need: #{(needs).inspect} (supply: #{supply.inspect})"

    needs.keys.each do |ingredient|
      next if ingredient == "ORE"
      amount_needed = needs.delete ingredient

      debug "  #{ingredient} needed: #{amount_needed}"

      # can we pull from existing supply?
      if supply[ingredient] >= amount_needed
        debug "    pulling entirety from supply"
        supply[ingredient] -= amount_needed
        next
      elsif supply[ingredient] > 0
        amount_needed -= supply[ingredient]
        debug "    pulling #{supply[ingredient]} #{ingredient} from supply -> only need #{amount_needed}"
        supply.delete ingredient
      end

      makes, ingredients = *recipe[ingredient]
      to_make = amount_needed / makes
      to_make += 1 if amount_needed % makes > 0

      ingredients.each do |name, amount|
        debug "    need #{amount * to_make} #{name} to make #{to_make} #{ingredient}"
        needs[name] += amount * to_make
      end

      # log any extras produced
      if amount_needed % makes > 0 # making more than we need
        extra = to_make * makes - amount_needed
        debug "      producing an extra #{extra} #{ingredient}"
        supply[ingredient] += extra
      end

      break if max_ore > 0 && needs["ORE"] > max_ore
    end
    debug "  => #{(needs).inspect}"

    if max_ore > 0
      ore_used = needs["ORE"]
      debug "  ore used: #{ore_used}"
      if ore_used >= max_ore
        puts if fuel_made > 1000
        break
      end
      if needs.length == 1 && needs.keys.first == "ORE"
        fuel_made += 1
        print "\r#{fuel_made}" if fuel_made % 1000 == 0
        needs["FUEL"] = 1
      end
    else
      break if needs.length == 1 && needs.keys.first == "ORE"
    end
  end

  debug "needs: #{(needs)} (supply #{supply.to_a})"

  [needs["ORE"], supply, fuel_made]
end

def part1(input, debug = false)
  $debug = debug
  recipe = parse input
  out = reduce recipe, "FUEL", 1
  out.first
end

def part1_matrix(input)
  recipe = recipe_rows input
  row_indices = recipe.map { |row| row.map(&:first).flatten }.flatten.uniq
  rows = Array.new(row_indices.size) { [] }
  recipe.each do |row|
    output = row.last[0]
    by_element = Hash[row]
    STDERR.puts "by_element: #{(by_element).inspect}"
    row_indices.each.with_index do |element, i|
      if (n = by_element[element])
        rows[i] << (element == output ? n : -n)
      else
        rows[i] << 0
      end
    end
  end
  require "matrix"
  matrix = Matrix.rows(rows)
  STDERR.puts "matrix: #{(matrix)}"
  STDERR.puts "det: #{matrix.lup.det}"
  # STDERR.puts "rows: #{(rows).pretty_inspect}"
  # STDERR.puts "recipe: #{(recipe).pretty_inspect}"
  nil
end

def part2(input, max_ore, debug = false)
  $debug = debug
  recipe = parse input
  ore, fuel = clean_reaction(recipe, "FUEL", 1)
  STDERR.puts "ore: #{(ore).inspect}"
  STDERR.puts "fuel: #{(fuel).inspect}"
  mult = max_ore / ore
  ore *= mult
  fuel *= mult
  STDERR.puts "#{ore} ore to cleanly generate #{fuel} fuel"
  remaining = reduce(recipe, "FUEL", 1, max_ore - ore)
  STDERR.puts "remaining: #{remaining[2]} fuel requiring #{remaining[0]} ore"
  STDERR.puts "total ore: #{fuel + remaining[2]}"
  remaining.last + fuel
end

def part2_v2(input, max_ore, debug = false)
  $debug = debug
  recipe = parse input
  ore, fuel = clean_reaction_2(recipe, "FUEL", 1)
end

def part2_binary_search(input, max_ore)
  recipe = parse input
  fuel_produced = (1..max_ore).bsearch do |fuel|
    print "testing #{fuel} FUEL..."
    ore = reduce(recipe, "FUEL", fuel).first
    puts " used #{ore}, diff #{max_ore - ore}, returning #{ore > max_ore}"
    ore > max_ore
  end
  fuel_produced - 1 # we found the first fuel _greater_ than max_ore
end

# returns [ore required, multiplier to make it clean]
def clean_reaction(recipe, ingredient, amount)
  $nest += 1
  debug "----- finding clean multiple for #{amount} #{ingredient}"
  ore, leftover, _ = reduce(recipe, ingredient, amount)
  if leftover.empty?
    debug "  --> #{ore} ORE, no leftovers"
    [ore, amount]
  else
    STDERR.puts "  --> #{ore} ORE, leftover: #{leftover}"
    parts = leftover.map do |i, a|
      next if a == 0
      from_recipe = recipe[i][0]
      multiplier = a.lcm(from_recipe) / a
      debug "  finding LCM for #{a * multiplier} #{i} (multiplier #{multiplier})"
      o, n = *clean_reaction(recipe, i, a * multiplier)
      [o, multiplier]
    end.compact
    debug "  parts: #{(parts).inspect}"
    lcm_all = parts.map(&:last).reduce(amount, &:lcm)
    debug "  lcm_all: #{(lcm_all).inspect}"
    savings = parts.map { |ore_saved, every_m| ore_saved * (lcm_all / every_m) }
    debug "  savings: #{savings}"
    debug [ore*lcm_all - savings.sum, amount * lcm_all].inspect
    [ore*lcm_all - savings.sum, amount * lcm_all]
  end
ensure
  $nest -= 1
end

part 1
with :part1, true
try ex1, 31

with :part1
try ex1, 31
# try ex2, 165
# try ex3, 13312
# try ex4, 180697
# try ex5, 2210736
# with :part1, false
# try puzzle_input
# with :part1_matrix
# try ex1, 31

# part 2
# fuel_made = ->(out) { out.last }
# with :part2_v2, 1000, true
# try ex1, 34
# with :part2, 10000, false
# try ex1, 344
# try ex2, 165
# try ex1, 31#, &ore_needed
# with :reduce_hash, 1_000, true
# try ex1
# with :reduce_hash, 1_000_000_000_000, true
# with :reduce_hash, 1_000_000_000_000, false
# try ex4, 5586022 # too slow
# with :part2, 1_000_000_000_000, true
# try ex3, 82892753 # too slow
# try puzzle_input
# try ex3, 82892753 # too slow
# try ex5, 460664#, &fuel_made # very slow, but works
# try puzzle_input, &fuel_made
part 2
with :part2_binary_search, 1_000_000_000_000
try ex3, 82892753
try ex4, 5586022
try ex5, 460664
try puzzle_input
