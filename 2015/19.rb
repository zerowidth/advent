require_relative "../toolkit"
require_relative "../graph_search"

Signal.trap("INT") { exit }

ATOMS = /[eA-Z][a-z]*/

ex1 = <<-EX
H => HO
H => OH
O => HH

HOH
EX

def part1(input)
  rules, input = input.split("\n\n", 2)
  rules = rules.split("\n").each_with_object(Hash.new) do |rule, hash|
    k, v = rule.strip.split(" => ", 2)
    hash[k] ||= []
    hash[k] << v
  end
  start = input.scan(ATOMS).to_a

  found = Set.new
  start.length.times do |i|
    if (matches = rules[start[i]])
      matches.each do |rule|
        replacement = start.dup
        replacement[i] = rule
        found << replacement.join("")
      end
    end
  end
  found.length
end

def lev(from, to)
  n = from.length
  m = to.length
  return m if n.zero?
  return n if m.zero?

  d = (0..m).to_a
  x = nil


  from.each.with_index(1) do |char1, i|
    j = 0
    while j < m
      cost = (char1 == to[j]) ? 0 : 1
      x = min3(
        d[j + 1] + 1, # insertion
        i + 1,      # deletion
        d[j] + cost # substitution
      )
      d[j] = i
      i = x

      j += 1
    end
    d[m] = x
  end

  x
end

def part2(input)
  rules, input = input.split("\n\n", 2)
  rules = rules.split("\n").each_with_object(Hash.new) do |rule, hash|
    k, v = rule.strip.split(" => ", 2)
    hash[k] ||= []
    hash[k] << v.scan(ATOMS).to_a
  end
  medicine = input.strip.scan(ATOMS).to_a

  iteration = 0
  search = GraphSearch.new do |config|
    # config.debug = true
    config.cost = ->(a, b) { 1 }
    config.heuristic = ->(a, b) { lev(a, b) }
    config.each_step = ->(_start, current, _came_from, _cost_so_far) do
      iteration += 1
      puts "#{iteration}: #{current.join} (#{lev(current, medicine)})"
    end
    config.neighbors = lambda do |molecule|
      neighbors = []
      i = molecule.length
      j = medicine.length
      while molecule[i] == medicine[j]
        i -= 1
        j -= 1
      end
      max_index = [i, 0].max

      # build from the right-most "bad" position:
      # puts "  #{molecule} max index #{max_index}"
      rules.each do |search, replacements|
        if molecule[max_index] == search
          replacements.each do |replacement|
            neighbors << molecule[0...max_index] + replacement + molecule[max_index+1..-1]
          end
        end
        # if (pos = molecule.rindex(search)) && pos + search.length >= max_index
        #   before = molecule[0...pos]
        #   replacements.each do |replacement|
        #     neighbors << molecule[0...pos] + replacement
        #   end
        # end
      end

      # atoms = molecule.scan(/[eA-Z][a-z]*/).to_a
      # rules.fetch(atoms.last, []).each do |replacement|
      #   neighbor = atoms[0..-2].join + replacement
      #   neighbors << neighbor if neighbor.length <= medicine.length
      # end

      
      # rules.each do |search, replacements|
      #   molecule.indices(search).reject { |pos| pos < min_index }.first(1).each do |pos|
      #     replacements.each do |replacement|
      #       before = molecule[0...pos]
      #       after = molecule[(pos + search.length)..]
      #       neighbor = before + replacement + after
      #       unless neighbor.length > medicine.length
      #         neighbors << neighbor 
      #       end
      #     end
      #   end
      # end

      neighbors
    end
    config.break_if = ->(current, _best) { current > medicine.length + 2 }
  end
  puts

  path, cost = search.path(start: ["e"], goal: medicine)
  puts "path:"
  puts path&.map(&:join).join("\n")
  cost
end

def part2_collapse(input)
  rules, input = input.split("\n\n", 2)
  rules = rules.split("\n").each_with_object(Hash.new) do |rule, hash|
    k, v = rule.strip.split(" => ", 2)
    hash[v] ||= []
    hash[v] << k
  end
  medicine = input.strip

  iteration = 0
  search = GraphSearch.new do |config|
    # config.debug = true
    config.cost = ->(a, b) { 1 }
    config.heuristic = ->(a, b) do
      a.lev(b) 
    end
    config.each_step = ->(_start, current, _came_from, _cost_so_far) do
      iteration += 1
      puts "#{iteration}: #{current} (#{"e".lev(current)})"
    end
    config.neighbors = lambda do |molecule|
      neighbors = []
      # max_index = molecule.length
      # max_index -= 1 while molecule[max_index] == medicine[max_index]
      # min_index += 1 while molecule[min_index] == medicine[min_index]

      # find what we can collapse:
      rules.each do |search, replacements|
        if (pos = molecule.index(search))
          replacements.each do |replacement|
            before = molecule[0...pos]
            after = molecule[(pos + search.length)..]
            neighbor = before + replacement + after
            neighbors << neighbor unless neighbor.count("e") > 1
          end
        end
      end
      neighbors
    end
    # config.cost = ->(_a, _b) { 1 }
    # config.break_if = ->(current, _best) { current > medicine.length + 2 }
  end
  puts

  path, cost = search.path(start: medicine, goal: "e")
  puts "path:"
  puts path&.join("\n")
  cost
end

part 1
with :part1
try ex1, expect: 4
try puzzle_input

ex2 = <<-EX
e => H
e => O
H => HO
H => OH
O => HH

HOH
EX

ex3 = <<-EX
e => H
e => O
H => HO
H => OH
O => HH

HOHOHO
EX

part 2
with :part2
try ex2, expect: 3
# O
# HH
# HOH

try ex3, expect: 6
# H
# OH
# OOH
# OOHO
# HHOHO
# HOHOHO

try puzzle_input

# with :part2_collapse
# try ex2, expect: 3
# try ex3, expect: 6
# try puzzle_input
