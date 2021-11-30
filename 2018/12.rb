require_relative "../toolkit"

def part1(input, generations:)
  state, rules = input.split("\n\n")

  rules = rules.lines.map do |line|
    left, right = line.chomp.split(" => ")
    [left.chars, right]
  end.to_h

  pots = {}
  # state.split(": ", 2).last.chars.each.with_index do |char, i|
  #   pots[i] = char
  # end

  state = state.split(": ", 2).last.chars
  added = 0
  debug "#{0}: #{state.join}"

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

  state.map.with_progress(total: state.length).with_index { |c, i| c == "#" ? (i - added) : 0 }.sum
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
with :part1, generations: 50_000_000_000
try puzzle_input
