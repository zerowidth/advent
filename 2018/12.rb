require_relative "../toolkit"

def part1(input, generations: 20)
  state, rules = input.split("\n\n")

  rules = rules.lines.map do |line|
    left, right = line.chomp.split(" => ")
    [left.chars, right]
  end.to_h

  state = state.split(": ", 2).last.chars
  added = 0
  debug "#{0}: #{state.join}"
  state, added = iterate(rules, state, generations, added)
  state.map.with_index { |c, i| c == "#" ? (i - added) : 0 }.sum
end

def part2(input, generations:)
  state, rules = input.split("\n\n")

  rules = rules.lines.map do |line|
    left, right = line.chomp.split(" => ")
    [left.chars, right]
  end.to_h

  state = state.split(": ", 2).last.chars
  added = 0
  debug "#{0}: #{state.join}"

  # assume the pattern settles down after 5 blocks of 100 iterations
  increments = 5.times.map do
    state, added = iterate(rules, state, 100, added)
    state.map.with_index { |c, i| c == "#" ? (i - added) : 0 }.sum
  end

  per_hundred = increments.each_cons(2).map { |a, b| b - a }.uniq
  raise "dunno" if per_hundred.length > 1

  (generations / 100) * per_hundred.first
end

def iterate(rules, state, generations, added)
  generations.times_with_progress do |generation|
    # ensure there are enough empty pots
    while state.take(5) != %w(. . . . .)
      state.unshift "."
      added += 1
    end
    state.push(".") while state.last(5) != %w(. . . . .)

    state = [".", "."] + state.each_cons(5).map do |slice|
      rules[slice] || "."
    end

    debug "#{generation + 1}: #{state.join}" if debug?
  end

  [state, added]
end

ex1 = <<-EX
initial state: #..#.#..##......###...###

...## => #
..#.. => #
.#... => #
.#.#. => #
.#.## => #
.##.. => #
.#### => #
#.#.# => #
#.### => #
##.#. => #
##.## => #
###.. => #
###.# => #
####. => #
EX

part 1
with :part1, generations: 20
debug!
try ex1, expect: 325
no_debug!
try puzzle_input

part 2
# debug!
with :part2, generations: 1000
with :part2, generations: 50_000_000_000
try puzzle_input
