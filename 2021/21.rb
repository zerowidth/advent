require_relative "../toolkit"

def part1(input)
  p1 = input.lines.first.numbers.last
  p2 = input.lines.last.numbers.last
  [p1, p2]

  players = [[1, p1, 0], [2, p2, 0]]
  die = 0 # die is 0-indexed, we add 1 when we "roll"
  rolled = 0

  loop do
    num, pos, score = *players.first
    rolls = 3.times.map do
       v = die + 1
       rolled += 1
       die = (die + 1) % 100
       v
    end
    moves = rolls.sum
    pos = (((pos - 1) + moves) % 10) + 1
    score += pos
    debug "player #{num} rolls #{rolls} moves to #{pos} total score #{score}"
    players[0] = [num, pos, score]
    players = players.rotate
    break if score >= 1000
  end

  players.map(&:last).min * rolled
end

def part2(input)
  p1 = input.lines.first.numbers.last
  p2 = input.lines.last.numbers.last
  [p1, p2]

  # players = [[1, p1, 0], [2, p2, 0]]

  # every time the die rolls, universe splits
  # each turn we split three times, but max score is only 21
  # each player can only be in one of 10 positions, at most 21 times (but likely a lot less often)
  # can probably memoize?

  # start with: one turn (three rolls) -> 3 splits, then 3 splits, then 3 splits
end

ex1 = <<EX
Player 1 starting position: 4
Player 2 starting position: 8
EX

part 1
with :part1
debug!
try ex1, 739785
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, 444356092776315
no_debug!
try puzzle_input
