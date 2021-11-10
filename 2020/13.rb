require_relative "../toolkit"

ex1 = <<-EX
939
7,13,x,x,59,x,31,19
EX

def part1(input)
  time, buses = *input.split("\n", 2)
  time = time.to_i
  buses = buses.strip.split(",").reject { |b| b == "x" }.map(&:to_i)
  earliest = buses.map do |bus|
    [bus, (time.to_f / bus).ceil * bus]
  end.min_by(&:last)
  earliest[0] * (earliest[1] - time)
end

def part2(input)
  departures = input.each_line.to_a.last.strip.split(",").map do |d|
    d == "x" ? d : d.to_i
  end

  to_find = departures.each.with_index.to_a

  # find_next(departures, departures.first)
end

def find_next(departures, t)
  # looking 
end

part 1
with :part1
try ex1, expect: 295
try puzzle_input

part 2
with :part2
try "17,x,13,19", 3417
try "67,7,59,61", 754018
try "67,x,7,59,61", 779210
try ex1, expect: 1068788
try puzzle_input
