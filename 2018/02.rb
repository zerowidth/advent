require_relative "../toolkit"

def checksum(input)
  twos = threes = 0
  input.split("\n").map do |word|
    counts = word.each_char.group_by{|c|c}.values.map(&:length)
    twos += 1 if counts.count(2) > 0
    threes += 1 if counts.count(3) > 0
  end
  twos * threes
end

def score(word)
  two = false
  three = false
  [two, three].select{|c|c}.size
end

ex1 = <<-EX
abcdef
bababc
abbcde
abcccd
aabcdd
abcdee
ababab
EX

def find_common(input)
  words = input.split("\n")
  pair = words.combination(2).detect do |a,b|
    diff = 0
    (0..a.length).each do |i|
      diff += 1 if a[i] != b[i]
    end
    diff == 1
  end
  pair.first.each_char.zip(pair.last.each_char).select do |a,b|
    a == b
  end.map(&:first).join
end

ex2 = <<-EX
abcde
fghij
klmno
pqrst
fguij
axcye
wvxyz
EX

part 1
with :checksum
try ex1, 12
try puzzle_input

part 2
with :find_common
try ex2, "fgij"
try puzzle_input

