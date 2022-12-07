require_relative "../toolkit"

def unique_index(input, n)
  input.each_cons(n).with_index.detect do |chars, i|
    chars.uniq.length == n
  end.last + n
end

def part1(input)
  unique_index input.lines.first.chars, 4
end

def part2(input)
  unique_index input.lines.first.chars, 14
end

ex1 = <<EX
mjqjpqmgbljsphdztnvjfqwrcgsmlb
EX

ex2 = <<EX
bvwbjplbgvbhsrlpgdmjqwftvncz
EX

ex3 = <<EX
nppdvjthqldpwncqszvftbrmjlhg
EX

ex4 = <<EX
nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg
EX

ex5 = <<EX
zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw
EX

part 1
with :part1
debug!
try ex1, 7
try ex2, 5
try ex3, 6
try ex4, 10
try ex5, 11
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, 19
try ex2, 23
try ex3, 23
try ex4, 29
try ex5, 26
no_debug!
try puzzle_input
