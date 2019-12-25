require_relative "../toolkit"

ex1 = <<-EX
deal with increment 7
deal into new stack
deal into new stack
EX

ex2 = <<-EX
cut 6
deal with increment 7
deal into new stack
EX

ex3 = <<-EX
deal with increment 7
deal with increment 9
cut -2
EX

ex4 = <<-EX
deal into new stack
cut -2
deal with increment 7
cut 8
cut -4
deal with increment 7
cut 3
deal with increment 9
deal with increment 3
cut -1
EX

def part1(input, deck_size:)
  deck = (0...deck_size).to_a.map(&:to_s)
  input.split("\n").each do |line|
    case line
    when /deal into new stack/
      STDERR.puts "-> new stack"
      deck = deck.reverse
    when /cut (-?\d+)/
      STDERR.puts "-> cut #{$1}"
      cut = $1.to_i
      if cut < 0
        cut = deck.length - cut.abs
      end
      deck = deck.drop(cut) + deck.take(cut)
    when /deal with increment (\d+)/
      STDERR.puts "-> increment #{$1}"
      table = Array.new(deck.length)
      inc = $1.to_i
      0.step(deck.length * inc - 1, inc).with_index do |o, i|
        table[o % deck.length] = deck[i]
      end
      deck = table
    end
  end
  deck
end

part 1
with :part1, deck_size: 10
try ex1, expect: %w(0 3 6 9 2 5 8 1 4 7)
try ex2, expect: %w(3 0 7 4 1 8 5 2 9 6)
try ex3, expect: %w(6 3 0 7 4 1 8 5 2 9)
try ex4, expect: %w(9 2 5 8 1 4 7 0 3 6)
with :part1, deck_size: 10007
try puzzle_input do |deck|
  deck.index "2019"
end

