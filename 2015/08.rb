require_relative "../toolkit"

def matchsticks(input)
  sum = 0
  input.lines.map do |line|
    line = line.gsub /\s/, ""
    next if line.length == 0
    sum += yield line
  end
  sum
end

def count_chars(input)
  chars = input.chars
  count = 0
  while char = chars.shift
    if char == '\\'
      if chars.first == '"' || chars.first == '\\'
        chars.shift
      elsif chars[0] == 'x'
        3.times { chars.shift }
      end
    end
    count += 1
  end
  count
end

def encode(line)
  final = ['"']
  line.chars.each do |char|
    case char
    when '"', '\\'
      final << '\\'
    end
    final << char
  end
  final << '"'
  final.join
end

def part_one(line)
  code = line.length
  data = count_chars(line[1..-2])
  code - data
end

def part_two(line)
  encode(line).length - line.length
end

part 1
with :matchsticks, &method(:part_one)
try '""', 2
try '"abc"', 2
try '"aaa\\"aaa"', 3
try '"\x27"', 5
try '"\\\\"', 2
try puzzle_input

part 2
with :matchsticks, &method(:part_two)
try '""', 4
try '"abc"', 4
try '"aaa\\"aaa"', 6
try '"\x27"', 5
try puzzle_input
