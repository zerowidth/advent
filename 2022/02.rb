require_relative "../toolkit"

WINS = {
  rock: :scissors,
  scissors: :paper,
  paper: :rock
}
TO_WIN = WINS.invert

SCORING = %i[rock paper scissors]

def part1(input)
  mapping = {
    "X" => :rock,
    "Y" => :paper,
    "Z" => :scissors,
    "A" => :rock,
    "B" => :paper,
    "C" => :scissors
  }

  input.lines_of(:words).map do |pair|
    them = mapping[pair[0]]
    us = mapping[pair[1]]

    score = SCORING.index(us) + 1
    if us == them
      score += 3
    elsif WINS[us] == them
      score += 6
    end

    score
  end.sum
end

def part2(input)
  mapping = {
    "A" => :rock,
    "B" => :paper,
    "C" => :scissors
  }

  input.lines_of(:words).map do |pair|
    them = mapping[pair[0]]
    score = 0
    case pair[1]
    when "X" # lose
      us = WINS[them]
    when "Y" # draw
      us = them
      score = 3
    when "Z" # win
      us = TO_WIN[them]
      score = 6
    end

    score += SCORING.index(us) + 1
    score
  end.sum
end

ex1 = <<EX
A Y
B X
C Z
EX

part 1
with :part1
debug!
try ex1, 15
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, 12
no_debug!
try puzzle_input
