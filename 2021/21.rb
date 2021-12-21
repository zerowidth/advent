require_relative "../toolkit"

def part1(input)
  p1 = input.lines.first.numbers.last
  p2 = input.lines.last.numbers.last

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
    # debug "player #{num} rolls #{rolls} moves to #{pos} total score #{score}"
    players[0] = [num, pos, score]
    players = players.rotate
    break if score >= 1000
  end

  players.map(&:last).min * rolled
end

def part2(input, winning_score:)
  p1 = input.lines.first.numbers.last
  p2 = input.lines.last.numbers.last

  # every time the die rolls, universe splits
  # each turn we split three times, but max score is only 21
  # each player can only be in one of 10 positions, at most 21 times (but likely a lot less often)
  # can probably memoize?
  @bar = progress_bar(title: "games")
  @memo = {}
  wins = winners(p1, p2, 0, 0, 0, 0, win: winning_score)
  @bar.finish
  puts "wins: #{wins}"
  wins.max
end

# since the game only iterates every three rolls, we can precalculate the rolls
# and since the total doesn't change either, we can just use that instead of arrays
ROLLS = [1, 2, 3].repeated_permutation(3).map(&:sum).to_a

# every time the die rolls, universe splits
# each turn we split three times, but max score is only 21
# each player can only be in one of 10 positions, at most 21 times (but likely a lot less often)
# can probably memoize?
#
# state: p1 [pos, score] p2 [pos, score] what turn it is, and the last three dice rolls
# we know a turn ended when roll % 3 == 0
# whose turn was it? (roll / 3) % 2

# return: number of wins by player, so either a [0, 1] or a [1, 0]
# and then sum them up
#
# memoize on all keys
#
# optimization: instead of each actual turn (mod 3) use p1 = turn.odd? and
# increment every 3 rolls.
def winners(p1, p2, s1, s2, turn, rolls, win:)
  @bar.advance
  key = [p1, p2, s1, s2, turn, rolls]
  return @memo[key] if @memo[key]

  if turn > 0
    pos = turn.odd? ? p1 : p2
    score = turn.odd? ? s1 : s2
    moves = rolls
    pos = (((pos - 1) + moves) % 10) + 1
    score += pos
    return turn.odd? ? [1, 0] : [0, 1] if score >= win

    if turn.odd?
      p1 = pos
      s1 = score
    else
      p2 = pos
      s2 = score
    end
  end

  totals = ROLLS.map do |next_rolls|
    winners(p1, p2, s1, s2, turn + 3, next_rolls, win: win)
  end.transpose
  debug (" " * turn) + "totals #{totals}" if debug?
  @memo[key] = totals.map(&:sum)
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
with :part2, winning_score: 10
debug!
try ex1, 18973591
with :part2, winning_score: 21
no_debug!
try ex1, 444356092776315
try puzzle_input
