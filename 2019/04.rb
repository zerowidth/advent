require_relative "../toolkit"

def part1(input)
  range = input.strip.split("-").map(&:to_i)
  passwords_within(*range).length
end

def part2(input)
  range = input.strip.split("-").map(&:to_i)
  passwords_within(*range) do |chars|
    if chars.uniq.length < chars.length
      groups = chars.group_by { |c| c }.values
      groups.map(&:length).any? { |l| l == 2 }
    else
      true
    end
  end.length
end

# thanks charliesome!
def regex_part1(input)
  range = input.strip.split("-").map(&:to_i)
  re = /\A(?=0*1*2*3*4*5*6*7*8*9*\z)(?=.*(.)\1)\d{6}\z/
  (range[0]..range[1]).map(&:to_s).grep(re).count
end

def regex_part2(input)
  range = input.strip.split("-").map(&:to_i)
  re = /\A(?=0*1*2*3*4*5*6*7*8*9*\z)(?=.*(.)(?!\1)(.)\2(?!\2)|(.)\3(?!\3))\d{6}\z/
  (range[0]..range[1]).map(&:to_s).grep(re).count
end

def passwords_within(start, finish, &block)
  start.upto(finish).select do |password|
    cs = password.to_s.chars
    block ||= ->(cs) { true }

    # len = cs.length == 6
    # repeated = cs.uniq.length < cs.length
    # increasing = cs.sort == cs
    # result = block.call(cs)
    # puts "#{cs.inspect} - #{len} #{repeated} #{increasing} #{result}"

    cs.length == 6 &&
    cs.uniq.length < cs.length &&
    cs.sort == cs &&
    block.call(cs)
  end
end

part 1
with :part1
try "111111-111111", 1
try "223450-223450", 0
try "123789-123789", 0
try puzzle_input

part 2
with :part2
try "111111-111111", 0
try "112233-112233", 1
try "123444-123444", 0
try "111122-111122", 1
try "112223-112223", 1
try puzzle_input

part 1
with :regex_part1
try "111111-111111", 1
try "223450-223450", 0
try "123789-123789", 0
try puzzle_input

part 2
with :regex_part2
try "111111-111111", 0
try "112233-112233", 1
try "123444-123444", 0
try "122333-122333", 1
try puzzle_input
