require_relative "../toolkit"

def nice_words(input)
  input.lines.select { |line| yield line }.count
end

part 1
with(:nice_words) do |line|
  vowels = line.scan(/[aeiou]/)
  repeated = line =~ /(.)\1/
  bad = line =~ /ab|cd|pq|xy/
  vowels.size >= 3 && repeated && !bad
end

try "ugknbfddgicrmopn", 1
try "aaa", 1
try "jchzalrnumimnmhp", 0
try "haegwjzuvuyypxyu", 0
try "dvszwmarrgswjxmb", 0
try puzzle_input

part 2
with(:nice_words) do |line|
  repeated = line =~ /(..).*\1/
  repeat_with_one_between = line =~ /(.).\1/
  repeated && repeat_with_one_between
end

try "qjhvhtzxzqqjkmpb", 1
try "xxyxx", 1
try "uurcxstgmygtbstg", 0
try "ieodomkazucvgmuy", 0
try puzzle_input
