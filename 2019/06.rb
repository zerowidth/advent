require_relative "../toolkit"

def get_orbits(input)
  orbits = {}
  input.split.map(&:strip).each do |line|
    a, b = *line.split(")")
    orbits[b] = a
  end
  orbits
end

def orbit_counts(input)
  orbits = get_orbits(input)
  count = 0
  orbits.keys.each do |obj|
    while (obj = orbits[obj])
      count += 1
    end
  end
  count
end

def to_santa(input)
  orbits = get_orbits input
  to_you = from_center_of_mass orbits, "YOU"
  to_santa = from_center_of_mass orbits, "SAN"
  # STDERR.puts "to_you: #{(to_you).inspect}"
  # STDERR.puts "to_santa: #{(to_santa).inspect}"
  while to_you.first == to_santa.first
    to_you.shift
    to_santa.shift
  end
  [to_you, to_santa].flatten.length
end

def from_center_of_mass(orbits, obj)
  path = []
  while (obj = orbits[obj])
    path << obj
  end
  path.reverse
end

ex1 = <<-EX
COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L
EX

ex2 = <<-EX
COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L
K)YOU
I)SAN
EX

part 1
with :orbit_counts
try "COM)B", 1
try ex1, 42
try puzzle_input

part 2
with :to_santa
try ex2, 4
try puzzle_input
