require_relative "../toolkit"

def seating_happiness(input)
  units = parse(input)
  units = yield units if block_given?
  people = units.keys

  scores = people.permutation.map do |ps|
    ps << ps.first
    # print ps.join(" -> ")
    s = ps.each_cons(2).map { |a, b| units[a][b] + units[b][a] }
    # puts " : #{s.inspect} #{s.sum}"
    s.sum
  end
  scores.max
end

def parse(input)
  units = Hash.new { |h, k| h[k] = {} }
  input.lines.each do |line|
    if line =~ /(\w+) would (gain|lose) (\d+) happiness units by sitting next to (\w+)\./
      units[$1][$4] = $3.to_i * ($2 == "gain" ? 1 : -1)
    else
      raise "what? #{line.inspect}"
    end
  end
  units
end

example = <<-EX
Alice would gain 54 happiness units by sitting next to Bob.
Alice would lose 79 happiness units by sitting next to Carol.
Alice would lose 2 happiness units by sitting next to David.
Bob would gain 83 happiness units by sitting next to Alice.
Bob would lose 7 happiness units by sitting next to Carol.
Bob would lose 63 happiness units by sitting next to David.
Carol would lose 62 happiness units by sitting next to Alice.
Carol would gain 60 happiness units by sitting next to Bob.
Carol would gain 55 happiness units by sitting next to David.
David would gain 46 happiness units by sitting next to Alice.
David would lose 7 happiness units by sitting next to Bob.
David would gain 41 happiness units by sitting next to Carol.
EX

with :seating_happiness
try example, 330
# try puzzle_input
with(:seating_happiness) do |units|
  units.keys.each { |k| units[k]["me"] = 0 }
  units["me"] = Hash.new(0)
  units
end
try example, 286 # ex post facto value, but hey
try puzzle_input
