require_relative "../toolkit"

BASE_PATTERN = [0, 1, 0, -1]

def generate_patterns(length)
  length.times.map do |elem|
    repeats = elem + 1
    pattern = BASE_PATTERN.inject([]) { |pat, v| pat << [v] * repeats }.flatten
    pattern *= 2 while pattern.length <= length
    pattern.drop(1)
  end
end

def fft(list, phases)
  patterns = generate_patterns list.length
  phases.times do |phase|
    print "."
    out = Array.new(list.length, 0)
    list.length.times.each do |elem|
      total = list.length.times.inject(0) do |sum, i|
        sum += list[i] * patterns[elem][i]
      end
      out[elem] = total.abs % 10
    end
    list = out
  end
  puts
  list
end

def part1(input, phases)
  list = input.strip.split("").map(&:to_i)
  fft(list, phases).join("")[0...8]
end

# basic brute force version
def part2_brute(input, phases, repeats, offsets)
  digits = input.strip.split("").map(&:to_i)
  out = fft(digits * repeats, phases)
  STDERR.puts "o: #{(out.join("")).inspect}"
  offsets.map { |o| out[o] }.join("")
end

# more efficient version, only calculates what's needed for the given offsets
def part2_efficiency(input, phases, repeats, offsets)
  digits = input.strip.split("").map(&:to_i)

  puts "generating offsets"
  required = Array.new(digits.length * repeats, 0)
  to_check = offsets.to_a
  until to_check.empty?
    elem = to_check.shift
    elem.upto(digits.length * repeats) do |i|
      pattern = BASE_PATTERN[((i + 1) / (elem + 1)) % 4]
      if pattern != 0 && required[i] == 0
        required[i] = 1
        to_check << i
      end
    end
  end
  print "  -> efficiency: #{"%0.2f" % (required.count(1).to_f * 100 / (digits.length * repeats))} "
  puts "(#{required.count(1)} out of #{digits.length * repeats})"

  puts "generating input list"
  list = Array.new(digits.length * repeats)
  elements = []
  required.each.with_index do |v, i|
    if v > 0
      elements << i
      list[i] = digits[i % digits.length]
    end
  end
  # STDERR.puts "required: #{(required).inspect}"
  # STDERR.puts "list: #{(list).inspect}"

  print "performing fft"
  phases.times do |phase|
    out = Array.new(digits.length * repeats)
    elements.each do |elem|
      sum = 0
      elements.each do |i|
        pattern = BASE_PATTERN[((i + 1) / (elem + 1)) % 4]
        sum += list[i] * pattern
      end
      out[elem] = sum.abs % 10
    end
    list = out
    y = (digits.length * repeats).times.map { |i| list[i] ? list[i] : " "  }.join("")
    print "."
  end
  puts

  x = (digits.length * repeats).times.map { |i| elements.include?(i) ? "x" : " " }.join("")
  STDERR.puts "x: #{(x).inspect}"
  y = (digits.length * repeats).times.map { |i| list[i] ? list[i] : " "  }.join("")
  STDERR.puts "y: #{(y).inspect}"

  offsets.map { |o| list[o] }.join("")
end

# more efficient version, only calculates what's needed for the given offsets
def part2_ranges(input, phases, repeats, offsets)
  digits = input.strip.split("").map(&:to_i)
  offset = offsets.first
  max = digits.length * repeats
  if offset.to_f / max <= 0.5
    raise ArgumentError, "too inefficient!"
  end

  # don't need a mostly empty list, just grab the digits we need
  list = Array.new(max - offset)
  offset.upto(max - 1) do |i|
    list[i-offset] = digits[i % digits.length]
  end

  print "performing fft"
  phases.times do |phase|
    # the trick here is that if the starting offset is more than halfway through
    # the input list, then the pattern is merely 1, repeating, for the remainder
    # of the input list. that means each element is just the sum (mod 10) of the
    # current element and all subsequent elements.
    #
    # A further optimization so the sum of each sub-range isn't needed over and
    # over is to start with the sum of the longest sequence, and subtract the
    # current input from that to get the sum for the next element.
    out = Array.new(list.length)
    sum = list.sum
    list.each.with_index do |value, i|
      out[i] = sum.abs % 10
      sum -= value
    end
    list = out
    print "."
  end
  puts

  offsets.map { |o| list[o-offset] }.join("")
end

def pattern(elem, i)
  # i += offsets the pattern, elem + 1 is how many repeats
  BASE_PATTERN[((i + 1) / (elem + 1)) % BASE_PATTERN.length]
end

ex1 = "12345678"
ex2 = "80871224585914546619083218645595"
ex3 = "19617804207202209144916044189917"
ex4 = "69317163492948606335995924319873"

part 1
with :part1, 1
try ex1, "48226158"
with :part1, 4
try ex1, "01029498"
with :part1, 100
try ex2, "24176176"
try ex3, "73745418"
try ex4, "52432133"
try puzzle_input

ex5 = "03036732577212944063491565474664"

part 2

with :part2_brute, 10, 2
try ex5, (40..42), "237"
with :part2_efficiency, 10, 2
try ex5, (40..42), "237"
with :part2_ranges, 10, 2
try ex5, (40..42), "237"

with :part2_brute, 100, 20
try ex5, (440...448), "66244648"
with :part2_efficiency, 100, 20
try ex5, (440...448), "66244648"
puts "baseline is 2.1 seconds"
with :part2_ranges, 100, 20
try ex5, (440...448), "66244648"

with :part2_ranges, 100, 10_000
o = (ex5[0...7].to_i)
try ex5, (o..(o+7)), "84462026"
o = (puzzle_input[0...7].to_i)
try puzzle_input, (o..(o+7))
