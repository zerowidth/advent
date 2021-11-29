require_relative "../toolkit"

def part1(input)
  players, last_marble = input.scan(/\d+/).map(&:to_i)

  scores = Hash.new(0)
  marbles = [0]
  player = 1 # 1-indexed for debugging
  current_marble = 0 # value of marble, not index!

  bar = progress_bar(total: last_marble - 1) unless debug?
  1.upto(last_marble) do |marble|
    if marble % 23 == 0
      # add this marble's score:
      scores[player] += marble
      # take 7 marbles counterclockwise:
      i = (marbles.index(current_marble) - 7) % marbles.length
      # and current is the one just clockwise from it
      current_marble = marbles[(i + 1) % marbles.length]
      removed = marbles.delete_at(i)
      scores[player] += removed
    else
      # place the marble after one space clockwise
      i = (marbles.index(current_marble) + 1) % marbles.length
      marbles.insert i + 1, marble
      current_marble = marble
    end

    ms = marbles.map { |m| m == current_marble ? m.to_s.green : m.inspect }.join(" ")
    debug "[#{player}] #{ms}"

    player = (player % players) + 1
    bar.advance unless debug?
  end
  bar.finish unless debug?

  debug "scores: #{scores}"
  scores.values.max
end

# def part2(input)

# end

ex1 = <<-EX
9 players; last marble is worth 25 points
EX

ex2 = <<EX
10 players; last marble is worth 1618 points
EX

ex3 = <<EX
13 players; last marble is worth 7999 points
EX

part 1
debug!
with :part1
try ex1, expect: 32
no_debug!
try ex2, expect: 8317
try ex3, expect: 146373
try puzzle_input

part 2
with :part2
debug!
try ex1, expect: nil
no_debug!
try puzzle_input
