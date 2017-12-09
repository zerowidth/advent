require_relative "../toolkit"

def groups(input)
  chars = input.chars.to_a
  i = 0
  group = 0
  garbage = false
  garbage_count = 0
  count = 0
  score = 0
  while i < chars.size
    char = chars[i]
    if !garbage && char == "<"
      garbage = true
    elsif garbage && char == ">"
      garbage = false
    elsif char == "!"
      i += 1
    elsif garbage
      garbage_count += 1
    elsif !garbage && char == "{"
      group += 1
    elsif !garbage && char == "}"
      score += group
      group -= 1
      count += 1
    end
    i += 1
  end

  yield count, score, garbage_count
end

part 1
with(:groups) { |c, s, g| c }
try "{}", 1
try "{{{}}}", 3
try "{{},{}}", 3
try "{{{},{},{{}}}}", 6
try "{<{},{},{{}}>}", 1
try "{<a>,<a>,<a>,<a>}", 1
try "{{<a>},{<a>},{<a>},{<a>}}", 5
try "{{<!>},{<!>},{<!>},{<a>}}", 2


with(:groups) { |c, s, g| s }

try "{}", 1
try "{{{}}}", 6
try "{{},{}}", 5
try "{{{},{},{{}}}}", 16
try "{<a>,<a>,<a>,<a>}", 1
try "{{<ab>},{<ab>},{<ab>},{<ab>}}", 9
try "{{<!!>},{<!!>},{<!!>},{<!!>}}", 9
try "{{<a!>},{<a!>},{<a!>},{<ab>}}", 3

try puzzle_input

part 2
with(:groups) { |c, s, g | g }

try "<>", 0
try "<random characters>", 17
try "<<<<>", 3
try "<{!>}>", 2
try "<!!>", 0
try "<!!!>>", 0
try "<{o\"i!a,<{i<a>", 10

try puzzle_input
