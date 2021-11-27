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

# part 2
# with :part2
# try ex1, expect: nil
# try puzzle_input
