require_relative "../toolkit"

# doubly linked list
class Marble
  attr_reader :value
  attr_accessor :next_marble, :prev_marble

  def initialize(value)
    @value = value
    @next_marble = nil
    @prev_marble = nil
  end

  def insert_after(marble)
    marble.next_marble = next_marble
    marble.prev_marble = self
    next_marble.prev_marble = marble
    @next_marble = marble
  end

  def delete
    prev_marble.next_marble = next_marble
    next_marble.prev_marble = prev_marble
    value
  end

  def clockwise(num)
    current = self
    num.times do
      current = current.next_marble
    end
    current
  end

  def counterclockwise(num)
    current = self
    num.times do
      current = current.prev_marble
    end
    current
  end
end

def high_score(players, last_marble)
  scores = Hash.new(0)

  player = 1
  zero = Marble.new(0)
  zero.next_marble = zero
  zero.prev_marble = zero
  current = zero

  bar = progress_bar(total: last_marble - 1) unless debug?
  1.upto(last_marble) do |marble|
    if marble % 23 == 0
      # add this marble's score:
      scores[player] += marble
      # remove the marble 7 counterclockwise, and set the next one to current
      current = current.counterclockwise(6)
      removed = current.counterclockwise(1).delete
      scores[player] += removed
    else
      # place the marble after one space clockwise
      marble = Marble.new(marble)
      current.clockwise(1).insert_after(marble)
      current = marble
    end

    if debug?
      ms = []
      cm = zero
      loop do
        ms << (cm == current ? cm.value.to_s.green : cm.value.to_s)
        cm = cm.next_marble
        break if cm == zero
      end
      debug "[#{player}] #{ms.join(" ")}"
    end

    player = (player % players) + 1
    bar.advance unless debug?
  end
  bar.finish unless debug?

  debug "scores: #{scores}"
  scores.values.max
end

def part1(input)
  players, last_marble = input.scan(/\d+/).map(&:to_i)
  high_score players, last_marble
end

def part2(input)
  players, last_marble = input.scan(/\d+/).map(&:to_i)
  high_score players, last_marble * 100
end

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
try puzzle_input
