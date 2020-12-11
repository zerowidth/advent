require_relative "../toolkit"

ex1 = <<-EX
16
10
15
5
1
11
7
19
6
12
4
EX

ex2 = <<-EX
28
33
18
42
31
14
46
20
48
47
24
23
49
45
19
38
39
11
1
32
25
35
8
17
7
9
4
2
34
10
3
EX

def part1(input)
  joltages = input.numbers.sort
  joltages << (joltages.last + 3)

  ones = 0
  threes = 0

  level = 0
  while adapter = joltages.shift
    diff = adapter - level
    if diff == 1
      ones += 1
    elsif diff == 3
      threes += 1 
    else
      raise "wtf, #{adapter}?"
    end
    level = adapter
  end

  [ones, threes, ones * threes]
end

def part2_recursive(input)
  adapters = [0] + input.numbers.sort
  adapters << (adapters.last + 3)
  diffs = adapters.each_cons(2).map { |a, b| b - a }
  puts adapters.inspect
  puts diffs.inspect
  parts = diffs.slice_when { |a, b| b == 3 }.map { |seq| seq.count(1) }.select { |c| c > 0 }
  puts parts.inspect
  puts parts.map { |part| threesum(part) }.inspect

  paths(adapters, adapters.first, adapters.last)
end

# this didn't work, too costly!
def paths(adapters, from, to)
  return 1 if from == to
  # puts "path from #{from} in #{adapters}"

  i = adapters.index(from)
  steps = adapters[i+1..i+4].select { |n| n - from <= 3 }
  # puts "steps at #{i}: #{steps}"
  return steps.map do |step|
    paths(adapters, step, to)
  end.sum
end

@threesums = { 1 => 1, 2 => 1, 3 => 2, 4 => 4, 5 => 7 }
def threesum(n)
  @threesums[n] ||= @threesums[n - 3] + @threesums[n - 2] + @threesums[n - 1]
end

1.upto(10) do |n|
  puts "threesum #{n} : #{threesum(n)}"
end

def part2_analytical(input)
  adapters = [0] + input.numbers.sort
  adapters << (adapters.last + 3)
  diffs = adapters.each_cons(2).map { |a, b| b - a }
  puts adapters.inspect
  puts diffs.inspect
  counts = diffs.slice_when { |a, b| b == 3 }.map { |seq| seq.count(1) }.select { |c| c > 1 }
  puts counts.inspect
  threes = counts.map { |count| threesum(count + 1) }
  puts threes.inspect
  threes.inject(&:*)
end

# if i have:
# 3 1 3 -> no options, can't skip any: 1 -> 0
# 3 1 1 3 -> can skip 0 or skip 1 -> 2 choices: 2 -> 2
# 3 1 1 1 3 -> can skip: (0) then 0 or 1, (1) then 
# 3 1 1 1 1 3 -> can skip: (0) then 0 1 2, (1) 0 1, (2) 0 1


part 1
with :part1
try ex1, expect: [7, 5, 35]
try ex2, expect: [22, 10, 220]
try puzzle_input

part 2
with :part2_recursive
try ex1, expect: 8
try ex2, expect: 19208
try "3", expect: 1
try "3 4", expect: 1
try "3 4 5", expect: 2
try "3 4 5 6", expect: 4
try "3 4 5 6 7", expect: 7
try "3 4 5 6 7 8", expect: 13
try "3 4 5 6 7 8 9", expect: 24
try "3 4 5 6 7 8 9 10", expect: 44
try "1", expect: 1
try "1 2", expect: 2
try "1 2 3", expect: 4
try "1 2 3 4", expect: 7

with :part2_analytical
try ex1, expect: 8
try ex2, expect: 19208
try puzzle_input
