require_relative "../toolkit"

def part1(input)
  counts = Hash.new(0)
  input.lines.map(&:chomp).each do |line|
    line.each_char.with_index { |c, i| counts[i] += 1 if c == "1" }
  end
  debug input.lines.length
  debug counts
  gamma = counts.sort_by(&:first).map { |_i, v| v > input.lines.length / 2 ? "1" : "0" }.join
  epsilon = gamma.tr("01", "10")
  debug "gamma #{gamma}"
  debug "eps #{epsilon}"
  gamma.to_i(2) * epsilon.to_i(2)
end

def get_oxygen(lines)
  debug "#{lines.length} total lines"
  length = lines.first.length
  (0...length).each do |i|
    ones = lines.map { |l| l[i] }.count("1")
    zeros = lines.length - ones
    debug "i #{i}: #{ones} ones #{zeros} zeros"
    if ones >= zeros
      debug "keeping 1"
      lines = lines.select { |line| line[i] == "1" }
    else
      debug "keeping 0"
      lines = lines.select { |line| line[i] == "0" }
    end
    break if lines.length == 1

    debug "#{lines.length} #{lines}"
  end
  lines.first.join.to_i(2)
end

def get_scrubber(lines)
  debug "#{lines.length} total lines"
  length = lines.first.length
  (0...length).each do |i|
    ones = lines.map { |l| l[i] }.count("1")
    zeros = lines.length - ones
    debug "i #{i}: #{ones} ones #{zeros} zeros"
    if ones >= zeros
      debug "keeping 0"
      lines = lines.select { |line| line[i] == "0" }
    else
      debug "keeping 1"
      lines = lines.select { |line| line[i] == "1" }
    end
    break if lines.length == 1

    debug "#{lines.length} #{lines}"
  end
  lines.first.join.to_i(2)

end

def part2(input)
  lines = input.lines.map(&:chomp).map(&:chars)

  oxygen = get_oxygen(lines)
  scrubber = get_scrubber(lines)

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
