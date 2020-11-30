require_relative "../toolkit"

def parse_sues(input)
  input.each_line.map do |line|
    line.strip!
    sue = {}
    num, attributes = line.split(": ", 2)
    sue["num"] = num.split(" ", 2).last.to_i


    attributes.split(", ").each do |pair|
      k, v = pair.split(": ")
      sue[k] = v.to_i
    end
    name, properties = line.split(":")
    values = properties.split(", ").map do |pair|
      k, v = pair.split(" ")
      [k, v.to_i]
    end
    sue
  end
end

def parse_patterns(patterns)
  patterns.split("\n").each_with_object({}) do |line, h|
    k, v = line.split(": ", 2)
    h[k] = v.to_i
  end
end


def part1(input, patterns)
  needles = parse_patterns(patterns)
  haystack = parse_sues(input)
  needles.each do |attr, value|
    haystack = haystack.select { |sue| sue[attr].nil? || sue[attr] == value }
  end

  haystack.first["num"]
end

def part2(input, patterns)
  needles = parse_patterns(patterns)
  haystack = parse_sues(input)
  needles.each do |attr, value|
    haystack = haystack.select do |sue|
      if sue[attr].nil?
        true
      else
        case attr
        when "cats", "trees"
          sue[attr] > value
        when "pomeranians", "goldfish"
          sue[attr] < value
        else
          sue[attr] == value
        end
      end
    end
  end

  haystack.first["num"]
end

NEEDLES = <<-LIST
children: 3
cats: 7
samoyeds: 2
pomeranians: 3
akitas: 0
vizslas: 0
goldfish: 5
trees: 3
cars: 2
perfumes: 1
LIST

part 1

with :part1, NEEDLES
try puzzle_input

with :part2, NEEDLES
try puzzle_input
