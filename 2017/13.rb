require_relative "../toolkit"

class Scanner
  attr_reader :depth, :range, :pos
  def initialize(depth, range)
    @depth = depth
    @range = range
    reset
  end

  def increment
    if (@pos == @range - 1 && @dir > 0 ) || (@pos == 0 && @dir < 0)
      @dir = -@dir
    end
    @pos += @dir
  end

  def reset
    @pos = 0
    @dir = 1
  end
end

def solution(input)
  severity = 0
  scanners = {}
  input.lines.map do |line|
    depth, range = line.strip.split(": ", 2).map(&:to_i)
    scanners[depth] = Scanner.new(depth, range)
  end

  scanners.values.map(&:reset)
  steps = scanners.keys.max
  0.upto(steps) do |step|
    if (scanner = scanners[step]) && scanner.pos == 0
      puts "caught at step #{step}"
      severity += scanner.depth * scanner.range
    end
    scanners.values.map(&:increment)
  end

  severity
end

class Seq
  def initialize(depth, range)
    @depth = depth
    @range = range
    @period = 2 * (@range - 1)
  end

  def clear?(n)
    (n + @depth) % @period != 0
  end
end


def delay(input)
  seqs = input.lines.map do |line|
    depth, range = line.strip.split(": ", 2).map(&:to_i)
    Seq.new(depth, range)
  end
  # seqs.map do |seq|
  #   puts seq.inspect
  #   vs = 0.upto(12).map { |n| seq.clear?(n) }
  #   puts vs.inspect
  # end
  delay = 0
  loop do
    print "\r#{delay}" if delay % 1000 == 0
    if seqs.all? { |s| s.clear?(delay) }
      break
    end
    delay += 1
  end
  delay
end

example = <<-EX
0: 3
1: 2
4: 4
6: 4
EX

part 1
with(:solution)
try example, 24
try puzzle_input

part 2
with(:delay)
try example, 10
try puzzle_input
