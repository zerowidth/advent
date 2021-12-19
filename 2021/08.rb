require_relative "../toolkit"

SEGMENTS_BY_DIGIT = {
  "a" => [0, 2, 3, 5, 6, 7, 8, 9],
  "b" => [0, 4, 5, 6, 8, 9],
  "c" => [0, 1, 2, 3, 4, 7, 8, 9],
  "d" => [2, 3, 4, 5, 6, 8, 9],
  "e" => [0, 2, 6, 8],
  "f" => [0, 1, 3, 4, 5, 6, 7, 8, 9],
  "g" => [0, 2, 3, 5, 6, 8, 9]
}

# DIGITS_BY_SEGMENT = Hash.of_array
# SEGMENTS_BY_DIGIT.each do |segment, digits|
#   digits.each { |digit| DIGITS_BY_SEGMENT[digit] << segment }
# end
DIGITS = {
  0 => %w[a b c e f g],
  2 => %w[a c d e g],
  3 => %w[a c d f g],
  5 => %w[a b d f g],
  6 => %w[a b d e f g],
  7 => %w[a c f],
  8 => %w[a b c d e f g],
  9 => %w[a b c d f g],
  4 => %w[b c d f],
  1 => %w[c f]
}.transform_values(&:to_set).map(&:reverse).to_h

def part1(input)
  input.lines.map do |line|
    line.split("|").last.words.count { |w| [2, 3, 4, 7].include? w.length }
  end.sum
end

def part2(input)
  input.lines.map do |line|
    signals, outputs = line.split("|").map(&:words)
    signals = signals.map(&:chars).map(&:to_set)
    outputs = outputs.map(&:chars)

    twos = signals.detect { |s| s.length == 2 }

    # only 7 has three
    seg_a = signals.detect { |s| s.length == 3 } - twos
    debug "seg_a: #{seg_a}"

    # only 6 doesn't match the signals from 1 and seg_c
    seg_f = signals.detect { |s| s.length == 6 && !twos.subset?(s) } & twos
    debug "seg_f: #{seg_f}"
    seg_c = twos - seg_f
    debug "seg_c: #{seg_c}"

    fives = signals.select { |s| s.length == 5 }.reduce(&:&)
    sixes = signals.select { |s| s.length == 6 }.reduce(&:&)
    seg_g = (fives & sixes) - seg_a
    debug "seg_g: #{seg_g}"

    seg_d = fives - seg_a - seg_g
    debug "seg_d: #{seg_d}"

    seg_b = sixes - seg_a - seg_f - seg_g
    debug "seg_b: #{seg_b}"

    seg_e = signals.detect { |s| s.length == 7 } - seg_a - seg_b - seg_c - seg_d - seg_f - seg_g
    debug "seg_e: #{seg_e}"

    mapping = {
      seg_a.first => "a",
      seg_b.first => "b",
      seg_c.first => "c",
      seg_d.first => "d",
      seg_e.first => "e",
      seg_f.first => "f",
      seg_g.first => "g"
    }

    outputs.map do |out|
      key = out.map { |c| mapping[c] }.to_set
      DIGITS[key]
    end.map(&:to_s).join.to_i
  end.sum
end

ex1 = <<EX
acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf
EX

ex2 = <<EX
be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
EX
part 1
with :part1
debug!
try ex2, 26
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, 5353
try ex2, 61229
no_debug!
try puzzle_input
