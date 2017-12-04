require_relative "../toolkit"

def valid?(input)
  words = input.split(/\s+/)
  words.size == words.uniq.size
end

def valid_count(input)
  input.lines.select do |line|
    valid?(line)
  end.size
end

def valid_with_anagram?(input)
  words = input.split(/\s+/)
  sorted = words.map { |w| w.chars.sort.join }.sort
  words.size == words.uniq.size && sorted.size == sorted.uniq.size
end

def valid_count_with_anagram(input)
  input.lines.select do |line|
    valid_with_anagram?(line)
  end.size
end

A = "aa bb cc dd ee" # is valid.
B = "aa bb cc dd aa" # is not valid - the word aa appears more than once.
C = "aa bb cc dd aaa" # is valid - aa and aaa count as different words.

part 1
with :valid?
try A, true
try B, false
try C, true

with :valid_count
try puzzle_input


part 2
D = "abcde fghij" # is a valid passphrase.
E = "abcde xyz ecdab" # is not valid - the letters from the third word can be rearranged to form the first word.
F = "a ab abc abd abf abj" # is a valid passphrase, because all letters need to be used when forming another word.
G = "iiii oiii ooii oooi oooo" # is valid.
H = "oiii ioii iioi iiio" # is not valid - any of these words can be rearranged to form any other word.

with :valid_with_anagram?
try D, true
try E, false
try F, true
try G, true
try H, false

with :valid_count_with_anagram
try puzzle_input
