require_relative "../toolkit"

POINTS = {
  ")" => 3,
  "]" => 57,
  "}" => 1197,
  ">" => 25137
}

PAIRS = {
  "(" => ")",
  "{" => "}",
  "[" => "]",
  "<" => ">"
}

def part1(input)
  input.lines_of(:chars).map do |line|
    debug "processing: #{line.join}"
    stack = []
    bad = nil
    line.each do |char|
      if (close = PAIRS[char])
        debug (" " * stack.size) + "open #{char}"
        stack << close
      elsif stack.last == char
        debug (" " * stack.size) + "close #{char}"
        stack.pop
      else
        debug (" " * stack.size) + "bad: #{char}"
        bad = char
        break
      end
    end
    POINTS[bad] || 0
  end.sum
end

CHAR_POINTS = [nil, ")", "]", "}", ">"]

def part2(input)
  sequences = []
  input.lines_of(:chars).map do |line|
    debug "processing: #{line.join}"
    stack = []
    bad = nil
    line.each do |char|
      if (close = PAIRS[char])
        stack << close
      elsif stack.last == char
        stack.pop
      else
        bad = char
        break
      end
    end
    sequences << stack.reverse unless bad
  end
  totals = sequences.map do |seq|
    points = seq.map { |c| CHAR_POINTS.index c }
    points.reduce(0) { |total, p| (total * 5) + p }
  end
  debug "totals: #{totals.sort}"
  totals.sort[(totals.length / 2)]
end

ex1 = <<EX
[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]
EX

part 1
with :part1
debug!
try ex1, 26397
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, 288957
no_debug!
try puzzle_input
