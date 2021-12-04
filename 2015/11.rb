require_relative "../toolkit"

STRAIGHTS = ('a'..'z').each_cons(3).map {|s| s.join }

def valid?(input)
  return false if input =~ /[iol]/
  return false unless STRAIGHTS.any? { |s| input.include? s }
  return false unless input.scan(/(.)\1/).flatten.uniq.length > 1
  true
end

def increment(input)
  input.succ
end

def next_password(input)
  loop do
    input = input.succ
    break if valid?(input)
  end
  input
end

def part1(input)
  next_password(input)
end

def part2(input)
  next_password(next_password(input))
end

part 1
with :valid?
try "hijklmmn", false
try "abbceffg", false
try "abbcegjk", false
try "abcdffaa", true
try "ghjaabcc", true
with :increment
try "a", "b"
try "z", "aa"
with :part1
try "abcdefgh", "abcdffaa"
try "ghijklmn", "ghjaabcc"
try puzzle_input

part 2
with :part2
try puzzle_input
