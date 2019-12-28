require_relative "../toolkit"

inc3 = <<-EX
deal with increment 3
EX

inc9 = <<-EX
deal with increment 9
EX

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

def part1(input, deck_size:, iterations: 1, debug_steps: false)
  deck = (0...deck_size).to_a.map(&:to_s)
  puts deck.inspect if debug_steps
  iterations.times do
    input.split("\n").each do |line|
      case line
      when /deal into new stack/
        # STDERR.puts "-> new stack"
        deck = deck.reverse
      when /cut (-?\d+)/
        # STDERR.puts "-> cut #{$1}"
        cut = $1.to_i
        if cut < 0
          cut = deck.length - cut.abs
        end
        deck = deck.drop(cut) + deck.take(cut)
      when /deal with increment (\d+)/
        # STDERR.puts "-> increment #{$1}"
        table = Array.new(deck.length)
        inc = $1.to_i
        0.step(deck.length * inc - 1, inc).with_index do |o, i|
          table[o % deck.length] = deck[i]
        end
        deck = table
      end
      puts deck.inspect if debug_steps
    end
  end
  deck
end

def invert(steps:, index:, deck_size:)
  # apply the transformations, or rather their inverse, to find the
  # dependency for the given index
  steps.each do |step, arg|
    prev = index
    case step
    when :new
      index = deck_size - 1 - index # swap position around the middle
      # STDERR.puts "new: #{prev} -> #{index}"
    when :cut
      # shift the index by the argument amount
      index += arg
      index += deck_size if index < 0
      index = index % deck_size
      # STDERR.puts "cut #{arg}: #{prev} -> #{index}"
    when :inc
      # if element at i goes to j = (i * arg) % deck_size
      # then element that went to j came from... have to find the multiplier
      # that has the given modulo of deck size
      # index = 0.step(arg * deck_size - 1, arg) do |j|
        # if j % deck_size == index
          # break j / arg
        # end
      # end
      # or: use inverse modulo:
      index = (index * arg.inverse_mod(deck_size)) % deck_size
      # STDERR.puts "inc #{arg}: #{prev} -> #{index}"
    end
  end
  index
end

def part2(input, deck_size:, iterations:, range:)
  steps = input.split("\n").map do |line|
    case line
    when /deal into new stack/
      [:new]
    when /cut (-?\d+)/
      [:cut, $1.to_i]
    when /deal with increment (\d+)/
      [:inc, $1.to_i]
    end
  end

  STDERR.puts "loaded #{steps.length} steps"

  # need them in reverse order to reconstruct which original position/card is
  # needed for a given final position.
  steps = steps.reverse

  range.map do |n|
    index = n
    count = 0

    iterations.times do
      STDERR.print "deck[#{n}] iteration #{count}: i = #{index}\r" if count % 10_000 == 0
      count += 1
      index = invert steps: steps, index: index, deck_size: deck_size

      # if we've hit a cycle, we can skip ahead:
      if index == n
        break
      end
    end

    if count < iterations
      STDERR.puts "index #{n}: cycle found at #{count}: #{iterations % count} additional required"
    end

    (iterations % count).times do
      index = invert steps: steps, index: index, deck_size: deck_size
    end

    index.to_s
  end
end

# combine ax + b, cx + d, mod m
def combine(a, b, c, d, m)
  x = a*c
  y = a*d + b
  [x % m, y % m]
end

def part2_analytical(input, deck_size:, iterations:, range:)
  multiplier = 1
  offset = 0

  input.split("\n").map do |line|
    case line
    when /deal into new stack/
      multiplier = -multiplier
      offset = - offset - 1
      STDERR.print "new -> m: #{multiplier} o: #{offset}"
    when /cut (-?\d+)/
      offset -= $1.to_i
      STDERR.print "cut #{$1} -> m: #{multiplier} o: #{offset}"
    when /deal with increment (\d+)/
      multiplier = multiplier * $1.to_i
      offset *= $1.to_i
      STDERR.print "inc #{$1} -> m: #{multiplier} o: #{offset}"
    else
      raise "wtf? #{line.inspect}"
    end
    # normalize:
    multiplier = multiplier % deck_size
    offset = offset % deck_size
    STDERR.puts " => m: #{multiplier} o: #{offset}"
  end

  digits = []
  n = iterations
  while n > 0
    digits << n % 2
    n = n / 2
  end

  factors = {}
  factors[1] = [multiplier, offset]
  1.upto(digits.length - 1).each do |n|
    two = 2**n
    factors[two] = combine(*factors[two/2], *factors[two/2], deck_size)
  end
  # STDERR.puts "factors: #{(factors).inspect}"
  # STDERR.puts "digits: #{(digits).inspect}"

  # iterations: f^n = decomposed into powers of two, with
  # f1(n) = an + b, f2(n) = f1(f1(i)), f4(n) = f2(f2(n)), ...
  a = 1
  b = 0
  digits.each.with_index do |digit, power|
    next unless digit == 1
    STDERR.print "f#{2**power}(x): #{a} #{b} -> "
    a, b = *combine(a, b, *factors[2**power], deck_size)
    STDERR.puts "#{a} #{b}"
  end

  inverse = a.inverse_mod(deck_size)
  STDERR.puts "invert -> a: #{inverse} b: #{b}"

  range.map do |i|
    ((i - b) * inverse) % deck_size
  end.map(&:to_s)
end

part 1
# with :part1, deck_size: 10
# try ex1, expect: %w(0 3 6 9 2 5 8 1 4 7)
# try ex2, expect: %w(3 0 7 4 1 8 5 2 9 6)
# try ex3, expect: %w(6 3 0 7 4 1 8 5 2 9)
# try ex4, expect: %w(9 2 5 8 1 4 7 0 3 6)
with :part1, deck_size: 10007
try puzzle_input, expect: 3749 do |deck|
  deck.index "2019"
end

part 2

# show the steps as they're calculated, for work on the part2 algorithm:
# with :part1, deck_size: 10, iterations: 1, debug_steps: true
# try ex4, expect: %w(9 2 5 8 1 4 7 0 3 6)
# try ex2

# try the algorithm for real:
# with :part2, deck_size: 10, iterations: 1, range: 0...10
# with :part2_analytical, deck_size: 10, iterations: 1, range: 0...10
# try inc3, expect: %w(0 7 4 1 8 5 2 9 6 3)
# try inc9, expect: %w(0 9 8 7 6 5 4 3 2 1)
# try ex1, expect: %w(0 3 6 9 2 5 8 1 4 7)
# try ex2, expect: %w(3 0 7 4 1 8 5 2 9 6)
# try ex3, expect: %w(6 3 0 7 4 1 8 5 2 9)
# try ex4, expect: %w(9 2 5 8 1 4 7 0 3 6)
# with :part2_analytical, deck_size: 10007, iterations: 1, range: 3749..3749
# try puzzle_input, expect: ["2019"]

# now, try multiple iterations:
with :part2, deck_size: 10, iterations: 2, range: 0...10
try ex1, expect: %w(0 9 8 7 6 5 4 3 2 1)
with :part2_analytical, deck_size: 10, iterations: 2, range: 0...10
# try inc3, expect: %w(0 9 8 7 6 5 4 3 2 1)
# try inc9, expect: %w(0 1 2 3 4 5 6 7 8 9)
try ex1, expect: %w(0 9 8 7 6 5 4 3 2 1)
# try ex2, expect: %w(4 3 2 1 0 9 8 7 6 5)
# try ex4, expect: %w(6 5 4 3 2 1 0 9 8 7)
# with :part2, deck_size: 10, iterations: 3, range: 0...10
with :part2_analytical, deck_size: 10, iterations: 3, range: 0...10
try ex4, expect: %w(7 4 1 8 5 2 9 6 3 0)
with :part2, deck_size: 10, iterations: 4, range: 0...10
with :part2_analytical, deck_size: 10, iterations: 4, range: 0...10
try ex4, expect: %w(0 1 2 3 4 5 6 7 8 9)
# with :part2, deck_size: 10, iterations: 40, range: 0...10
with :part2_analytical, deck_size: 10, iterations: 40, range: 0...10
try ex4, expect: %w(0 1 2 3 4 5 6 7 8 9)

with :part2_analytical, deck_size: 119315717514047, iterations: 101741582076661, range: 2020..2020
try puzzle_input do |out|
  out.first.to_i
end
