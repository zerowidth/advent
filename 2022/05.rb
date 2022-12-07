require_relative "../toolkit"

def crates(input)
  rows = input.sections.first.lines_of(:chars)
  cols = []
  0.upto(rows.map(&:length).max) do |i|
    col = []
    rows.each { |row| col << row[i] if row[i] =~ /\w/ }
    cols << col.reverse
  end
  stacks = {}
  cols.select { |c| c.first =~ /\d/ }.map do |c|
    stacks[c.first] = c[1..]
  end
  stacks
end

def part1(input)
  stacks = crates(input)
  debug stacks
  input.sections.last.lines.map do |instruction|
    raise "lol" unless instruction =~ /move (\d+) from (\d+) to (\d+)/
    $1.to_i.times do
      stacks[$3].push stacks[$2].pop
    end
    debug instruction
    debug stacks
  end
  stacks.values.map(&:last).join
end

def part2(input)
  stacks = crates(input)
  debug stacks
  input.sections.last.lines.map do |instruction|
    raise "lol" unless instruction =~ /move (\d+) from (\d+) to (\d+)/
    stacks[$3].concat stacks[$2].pop($1.to_i)
    debug instruction
    debug stacks
  end
  stacks.values.map(&:last).join
end

ex1 = <<EX
    [D]#{'    '}
[N] [C]#{'    '}
[Z] [M] [P]
 1   2   3#{' '}

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2
EX

part 1
with :part1
debug!
try ex1, "CMZ"
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, "MCD"
no_debug!
try puzzle_input
