require_relative "../toolkit"

def part1(input, moves:)
  cups = input.chomp.chars.map(&:to_i)
  min = cups.min
  max = cups.max

  moves.times_with_progress do |move|
    debug "-- move #{move} --"
    debug "cups: #{cups}"

    # take next three cups
    current = cups.first
    taken = cups.drop(1).take(3)
    debug "pick up: #{taken}"

    cups = cups.take(1) + cups.drop(4)

    # pick a destination cup
    dest = current - 1
    while taken.include?(dest) || dest < min
      dest -= 1
      dest = max if dest < min
    end
    debug "dest: #{dest}"
    debug "pre insert: #{cups}"

    cups.insert(cups.index(dest) + 1, *taken)
    cups = cups.rotate
  end

  # rotate cups so 1 is first, then drop it, then stringify
  cups.rotate(cups.index(1)).drop(1).map(&:to_s).join
end

def part2(input, moves:, total: nil)
  input = input.chomp.chars.map(&:to_i)

  cups = {} # hash { a => b }: cup a comes after b
  input.each.with_index do |cup, i|
    cups[cup] = input[i + 1] if i < input.length
  end

  if total
    debug input
    last = input.last
    (input.max + 1).upto(total) do |cup|
      cups[last] = cup
      last = cup
    end
    cups[last] = input.first
  else
    cups[input.last] = input.first
  end

  max = cups.keys.max
  current = input.first
  debug cups

  moves.times_with_progress do |move|
    debug "-- move #{move} --" if $debug
    if $debug
      array = [current]
      array << cups[array.last] while cups[array.last] != current
      debug "cups: #{cups} #{array}"
    end

    # take the next three
    taken = [cups[current], cups[cups[current]], cups[cups[cups[current]]]]
    # figure out where to put them
    dest = current - 1
    while taken.include?(dest) || dest < 1
      dest -= 1
      dest = max if dest < 1
    end
    debug "pick up: #{taken} insert after #{dest}" if $debug

    # update the pointers:
    cups[current] = cups[taken[2]]
    cups[taken[2]] = cups[dest]
    cups[dest] = taken[0]

    current = cups[current]
  end

  [cups[1], cups[cups[1]]]
end

ex1 = <<-EX
389125467
EX

part 1
with :part1, moves: 10
debug!
try ex1, expect: "92658374"
with :part1, moves: 100
try ex1, expect: "67384529"
no_debug!
try puzzle_input

part 2

debug!
with :part2, moves: 5
try ex1, expect: [3, 6]
with :part2, moves: 100, total: 20
try ex1, expect: [9, 6]

no_debug!
with :part2, moves: 10_000_000, total: 1_000_000
try ex1, expect: [934001, 159792]
with :part2, moves: 10_000_000, total: 1_000_000
try puzzle_input do |a, b|
  a * b
end
