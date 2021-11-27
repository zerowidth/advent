require_relative "../toolkit"

def parse_decks(input)
  input.split("\n\n").map do |player|
    player.split("\n", 2).last.numbers
  end
end

def part1(input)
  p1, p2 = *parse_decks(input)

  round = 0
  until p1.empty? || p2.empty?
    round += 1
    debug "round #{round}"
    debug "  player 1 #{p1}"
    debug "  player 2 #{p2}"
    p1_card = p1.shift
    p2_card = p2.shift
    if p1_card > p2_card
      p1.push(p1_card)
      p1.push(p2_card)
    else
      p2.push(p2_card)
      p2.push(p1_card)
    end
  end

  debug "game over: #{p1} vs #{p2}"
  winning_deck = p1.empty? ? p2 : p1
  winning_deck.reverse.map.with_index { |c, i| c * (i + 1) }.sum
end

# returns true if p1 wins
def game(num, p1, p2)
  seen = Set.new
  round = 0
  bar = progress_bar if num == 1
  until p1.empty? || p2.empty?
    bar.advance if num == 1
    round += 1
    debug "game #{num} round #{round}"
    debug "  player 1 #{p1}"
    debug "  player 2 #{p2}"

    if seen.include?([p1, p2])
      debug "  infinite recursion, p1 wins!"
      return p1, p2, true
    end

    seen << [p1.dup, p2.dup]

    p1_card = p1.shift
    p2_card = p2.shift

    if p1.length >= p1_card && p2.length >= p2_card
      _, _, p1_wins = game(num + 1, p1.take(p1_card), p2.take(p2_card))
      if p1_wins
        debug "  player 1 wins (recursively)"
        p1.push(p1_card)
        p1.push(p2_card)
      else
        debug "  player 2 wins (recursively)"
        p2.push(p2_card)
        p2.push(p1_card)
      end
    elsif p1_card > p2_card
      debug "  player 1 wins"
      p1.push(p1_card)
      p1.push(p2_card)
    else
      debug "  player 2 wins"
      p2.push(p2_card)
      p2.push(p1_card)
    end
  end
  bar.finish if num == 1

  [p1, p2, p2.empty?]
end

def part2(input)
  p1, p2 = *parse_decks(input)

  results = game(1, p1, p2)
  puts "results: #{results}"
  winning_deck = results[0].empty? ? results[1] : results[0]
  winning_deck.reverse.map.with_index { |c, i| c * (i + 1) }.sum
end

ex1 = <<-EX
Player 1:
9
2
6
3
1

Player 2:
5
8
4
7
10
EX

ex2 = <<EX
Player 1:
43
19

Player 2:
2
29
14
EX

part 1
with :part1
debug!
try ex1, expect: 306
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, expect: 291
try ex2, expect: 105 # i guess
no_debug!
try puzzle_input
