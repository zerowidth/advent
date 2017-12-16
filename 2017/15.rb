require_relative "../toolkit"

def solution(input)
  a, b = *input.lines.map do |line|
    line.split(" ").last.to_i
  end
  af = 16807
  bf = 48271
  div = 2147483647

  count = 0

  40_000_000.times do |n|
    print "\r#{n}" if n % 10_000 == 0
    a = (a * af) % div
    b = (b * bf) % div
    match = (a & 0xffff) == (b & 0xffff)
    count += 1 if match
  end
  puts
  count
end

def picky(input)
  a, b = *input.lines.map do |line|
    line.split(" ").last.to_i
  end
  af = 16807
  bf = 48271
  div = 2147483647

  count = 0
  5_000_000.times do |n|
    loop do
      a = (a * af) % div
      break if a % 4 == 0
    end
    loop do
      b = (b * bf) % div
      break if b % 8 == 0
    end
    match = (a & 0xffff) == (b & 0xffff)
    count += 1 if match
    print "\r#{n}" if n % 10_000 == 0
  end
  puts
  count
end

example = <<-EX
Generator A starts with 65
Generator B starts with 8921
EX

part 1
with(:solution)
try example, 588
try puzzle_input

part 2
with(:picky)
try example, 309
try puzzle_input
