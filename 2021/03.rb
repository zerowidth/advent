require_relative "../toolkit"

def part1(input)
  input = input.lines(chomp: true).map(&:chars)
  by_digit = input.shift.zip(*input).map(&:tally)
  debug "counts by digit: #{by_digit}"
  epsilon = by_digit.map { |counts| counts.max_by(&:last).first }.join.to_i(2)
  gamma = by_digit.map { |counts| counts.min_by(&:last).first }.join.to_i(2)
  epsilon * gamma
end

def filter_lines(lines)
  (0...lines.first.length).each do |i|
    counts = lines.map { |l| l[i] }.tally
    to_find = yield counts
    debug "i #{i}: #{counts}, keeping #{to_find}"
    lines = lines.select { |l| l[i] == to_find }
    break if lines.length == 1
  end
  debug lines.first.join
  lines.first.join.to_i(2)
end

def part2(input)
  lines = input.lines(chomp: true).map(&:chars)
  oxygen = filter_lines(lines) { |c| c["1"] >= c["0"] ? "1" : "0" }
  scrubber = filter_lines(lines) { |c| c["0"] <= c["1"] ? "0" : "1" }
  oxygen * scrubber
end

ex1 = <<EX
00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010
EX

part 1
with :part1
debug!
try ex1, expect: 198
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, expect: 230
no_debug!
try puzzle_input
