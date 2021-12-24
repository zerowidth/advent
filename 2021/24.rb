require_relative "../toolkit"

def monad(input)
  x = y = z = w = i = 0
  w = input[i]; i += 1
  x = x * 0
  x = x + z
  x = x % 26
  z = z / 1
  x = x + 11
  x = x == w ? 1 : 0
  x = x == 0 ? 1 : 0
  y = y * 0
  y = y + 25
  y = y * x
  y = y + 1
  z = z * y
  y = y * 0
  y = y + w
  y = y + 1
  y = y * x
  z = z + y
  w = input[i]; i += 1
  x = x * 0
  x = x + z
  x = x % 26
  z = z / 1
  x = x + 10
  x = x == w ? 1 : 0
  x = x == 0 ? 1 : 0
  y = y * 0
  y = y + 25
  y = y * x
  y = y + 1
  z = z * y
  y = y * 0
  y = y + w
  y = y + 10
  y = y * x
  z = z + y
  w = input[i]; i += 1
  x = x * 0
  x = x + z
  x = x % 26
  z = z / 1
  x = x + 13
  x = x == w ? 1 : 0
  x = x == 0 ? 1 : 0
  y = y * 0
  y = y + 25
  y = y * x
  y = y + 1
  z = z * y
  y = y * 0
  y = y + w
  y = y + 2
  y = y * x
  z = z + y
  w = input[i]; i += 1
  x = x * 0
  x = x + z
  x = x % 26
  z = z / 26
  x = x + -10
  x = x == w ? 1 : 0
  x = x == 0 ? 1 : 0
  y = y * 0
  y = y + 25
  y = y * x
  y = y + 1
  z = z * y
  y = y * 0
  y = y + w
  y = y + 5
  y = y * x
  z = z + y
  w = input[i]; i += 1
  x = x * 0
  x = x + z
  x = x % 26
  z = z / 1
  x = x + 11
  x = x == w ? 1 : 0
  x = x == 0 ? 1 : 0
  y = y * 0
  y = y + 25
  y = y * x
  y = y + 1
  z = z * y
  y = y * 0
  y = y + w
  y = y + 6
  y = y * x
  z = z + y
  w = input[i]; i += 1
  x = x * 0
  x = x + z
  x = x % 26
  z = z / 1
  x = x + 11
  x = x == w ? 1 : 0
  x = x == 0 ? 1 : 0
  y = y * 0
  y = y + 25
  y = y * x
  y = y + 1
  z = z * y
  y = y * 0
  y = y + w
  y = y + 0
  y = y * x
  z = z + y
  w = input[i]; i += 1
  x = x * 0
  x = x + z
  x = x % 26
  z = z / 1
  x = x + 12
  x = x == w ? 1 : 0
  x = x == 0 ? 1 : 0
  y = y * 0
  y = y + 25
  y = y * x
  y = y + 1
  z = z * y
  y = y * 0
  y = y + w
  y = y + 16
  y = y * x
  z = z + y
  w = input[i]; i += 1
  x = x * 0
  x = x + z
  x = x % 26
  z = z / 26
  x = x + -11
  x = x == w ? 1 : 0
  x = x == 0 ? 1 : 0
  y = y * 0
  y = y + 25
  y = y * x
  y = y + 1
  z = z * y
  y = y * 0
  y = y + w
  y = y + 12
  y = y * x
  z = z + y
  w = input[i]; i += 1
  x = x * 0
  x = x + z
  x = x % 26
  z = z / 26
  x = x + -7
  x = x == w ? 1 : 0
  x = x == 0 ? 1 : 0
  y = y * 0
  y = y + 25
  y = y * x
  y = y + 1
  z = z * y
  y = y * 0
  y = y + w
  y = y + 15
  y = y * x
  z = z + y
  w = input[i]; i += 1
  x = x * 0
  x = x + z
  x = x % 26
  z = z / 1
  x = x + 13
  x = x == w ? 1 : 0
  x = x == 0 ? 1 : 0
  y = y * 0
  y = y + 25
  y = y * x
  y = y + 1
  z = z * y
  y = y * 0
  y = y + w
  y = y + 7
  y = y * x
  z = z + y
  w = input[i]; i += 1
  x = x * 0
  x = x + z
  x = x % 26
  z = z / 26
  x = x + -13
  x = x == w ? 1 : 0
  x = x == 0 ? 1 : 0
  y = y * 0
  y = y + 25
  y = y * x
  y = y + 1
  z = z * y
  y = y * 0
  y = y + w
  y = y + 6
  y = y * x
  z = z + y
  w = input[i]; i += 1
  x = x * 0
  x = x + z
  x = x % 26
  z = z / 26
  x = x + 0
  x = x == w ? 1 : 0
  x = x == 0 ? 1 : 0
  y = y * 0
  y = y + 25
  y = y * x
  y = y + 1
  z = z * y
  y = y * 0
  y = y + w
  y = y + 5
  y = y * x
  z = z + y
  w = input[i]; i += 1
  x = x * 0
  x = x + z
  x = x % 26
  z = z / 26
  x = x + -11
  x = x == w ? 1 : 0
  x = x == 0 ? 1 : 0
  y = y * 0
  y = y + 25
  y = y * x
  y = y + 1
  z = z * y
  y = y * 0
  y = y + w
  y = y + 6
  y = y * x
  z = z + y
  w = input[i]; i += 1
  x = x * 0
  x = x + z
  x = x % 26
  z = z / 26
  x = x + 0
  x = x == w ? 1 : 0
  x = x == 0 ? 1 : 0
  y = y * 0
  y = y + 25
  y = y * x
  y = y + 1
  z = z * y
  y = y * 0
  y = y + w
  y = y + 15
  y = y * x
  z = z + y
  z
end

def part1(input)
  code = ["def monad(input)", "x = y = z = w = i = 0"]
  translated = input.lines.map do |line|
    case line
    when /inp (\w)/
      "#{$1} = input[i]; i += 1"
    when /add (\w) (-?\d+|\w)/
      "#{$1} = #{$1} + #{$2}"
    when /mul (\w) (-?\d+|\w)/
      "#{$1} = #{$1} * #{$2}"
    when /div (\w) (-?\d+|\w)/
      "#{$1} = #{$1} / #{$2}"
    when /mod (\w) (-?\d+|\w)/
      "#{$1} = #{$1} % #{$2}"
    when /eql (\w) (-?\d+|\w)/
      "#{$1} = #{$1} == #{$2} ? 1 : 0"
    else
      raise "what #{line}"
    end
  end
  code.concat translated
  code << "z"
  code << "end"

  puts "-" * 10
  puts code.join("\n")
  puts "-" * 10
  eval code.join("\n")

  found = nil
  (1..9).to_a.reverse.repeated_permutation(14).lazy.with_progress(total: 9 ** 14).each do |seq|
    if monad(seq).zero?
      found = seq
      break
    end
  end
  found
end

def part2(input)
  input.lines
end

part 1
with :part1
no_debug!
try puzzle_input

part 2
with :part2
# debug!
# try ex1, nil
no_debug!
try puzzle_input
