require_relative "../toolkit"

ex1 = <<-EX
light red bags contain 1 bright white bag, 2 muted yellow bags.
dark orange bags contain 3 bright white bags, 4 muted yellow bags.
bright white bags contain 1 shiny gold bag.
muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
dark olive bags contain 3 faded blue bags, 4 dotted black bags.
vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
faded blue bags contain no other bags.
dotted black bags contain no other bags.
EX

ex2 = <<-EX
shiny gold bags contain 2 dark red bags.
dark red bags contain 2 dark orange bags.
dark orange bags contain 2 dark yellow bags.
dark yellow bags contain 2 dark green bags.
dark green bags contain 2 dark blue bags.
dark blue bags contain 2 dark violet bags.
dark violet bags contain no other bags.
EX

def part1(input)
  rules = {}
  input.each_line.map(&:strip).map do |line|
    outer, rest = line.split(" bags contain ", 2)
    inner = rest.sub(".", "").split(", ").flat_map { |bag| bag.scan(/(\d+) (\w+ \w+) bags?/) }
    rules[outer] = inner
  end

  frontier = ["shiny gold"]
  containers = Set.new
  while (to_check = frontier.pop)
    rules.each do |container, contains|
      # puts "checking: #{container} can contain #{to_check}: #{contains.map(&:last)}"
      if contains.map(&:last).include? to_check
        frontier << container
        containers << container
      end
    end
  end

  containers.size
  
end

def part2(input)
  rules = {}
  input.each_line.map(&:strip).map do |line|
    outer, rest = line.split(" bags contain ", 2)
    inner = rest.sub(".", "").split(", ").map { |bag| bag.scan(/(\d+) (\w+ \w+) bags?/).flatten }
    rules[outer] = inner.map { |count, bag| [count.to_i, bag] }
  end

  # {"light red"=>[[1, "bright white"], [2, "muted yellow"]],
  #   "dark orange"=>[[3, "bright white"], [4, "muted yellow"]],
  #   "bright white"=>[[1, "shiny gold"]],
  #   "muted yellow"=>[[2, "shiny gold"], [9, "faded blue"]],
  #   "shiny gold"=>[[1, "dark olive"], [2, "vibrant plum"]],
  #   "dark olive"=>[[3, "faded blue"], [4, "dotted black"]],
  #   "vibrant plum"=>[[5, "faded blue"], [6, "dotted black"]],
  #   "faded blue"=>[[0, nil]],
  #   "dotted black"=>[[0, nil]]}

  frontier = [[1, "shiny gold"]]
  total_bags = 0
  while (node = frontier.pop)
    container_count, bag = *node
    # puts "seeing what goes in #{container_count} of #{bag}"
    rules[bag].each do |contained|
      contained_count, contained_bag = *contained
      if contained_count.positive?
        total_bags += (contained_count * container_count)
        frontier << [contained_count * container_count, contained_bag]
      end
    end
  end

  total_bags
end

part 1
with :part1
try ex1, expect: 4
try puzzle_input

part 2
with :part2
try ex2, expect: 126
try puzzle_input
