require_relative "../toolkit"

# def monad(input)
#   z = 0

#   z = (z * 26) + input[0] + 1  # could be anything?
#   z = (z * 26) + input[1] + 10 # could be anything?
#   z = (z * 26) + input[2] + 2 # (1-9) + 2 has to be 11-19, so this must be 9

#   z /= 26
#   # digit is 1-9, so z mod 26 must be between 11-19
#   z = (z * 26) + input[3] + 5 unless ((z % 26) - 10) == input[3]

#   z = (z * 26) + input[4] + 6 # could be anything?
#   z = (z * 26) + input[5] + 0 # could be anything?
#   z = (z * 26) + input[6] + 16 # (1-9) + 16 must be 12-20, so must be 1-4

#   z /= 26
#   # digit is 1-9, so z mod 26 must be between 12-20
#   z = (z * 26) + input[7] + 12 unless ((z % 26) - 11) == input[7]

#   z /= 26
#   # digit is 1-9, so z mod 26 must be between 8-16
#   z = (z * 26) + input[8] + 15 unless ((z % 26) - 7) == input[8]

#   z = (z * 26) + input[9] + 7 # 1-9 + 7 must be 14-22, so must be 7-9

#   z /= 26
#   # digit is 1-9, so z mod 26 must be between 14-22
#   z = (z * 26) + input[10] + 6 unless ((z % 26) - 13) == input[10]

#   z /= 26
#   # digit is 1-9, so z mod 26 must be 1-9
#   z = (z * 26) + input[11] + 5 unless (z % 26) == input[11]

#   z /= 26
#   # digit is 1-9, so z mod 26 must be between 12-20
#   z = (z * 26) + input[12] + 6 unless ((z % 26) - 11) == input[12]

#   # z must be < 26 at this point (it will be?)
#   z /= 26
#   # z mod 26 has to match final digit
#   z = (z * 26) + (input[13] + 15) unless (z % 26) == input[13]

#   z
# end

def valid?(input)
  # pre-validation:
  # return nil unless input[0] + 1 == input[13]
  # return nil unless input[1] + 10 - 11 == input[12]

  z = 0
  z = (z * 26) + input[0] + 1 # (1-9) + 1 must be 1-9, so 1-8 makes 2-9
  z = (z * 26) + input[1] + 10 # (1-9) + 10 must be 12-20, so 2-9 makes 12-19
  z = (z * 26) + input[2] + 2 # (1-9) + 2 must be 11-19, so 9 makes 11

  z /= 26
  # z mod 26 must be between 11-19: 11 - 10 means this must be 1
  return nil unless ((z % 26) - 10) == input[3]

  z = (z * 26) + input[4] + 6 # 7-15, must be 1-9 so must be 1-3 makes 7-9
  z = (z * 26) + input[5] + 0 # 8-16, must be 8-9
  z = (z * 26) + input[6] + 16 # (1-9) + 16 must be 12-20, so must be 1-4

  z /= 26
  # z mod 26 must be between 12-20: 1-4 + (16 - 11) = 6-9
  return nil unless ((z % 26) - 11) == input[7]

  z /= 26
  # z mod 26 must be between 8-16: thus, 8-9
  return nil unless ((z % 26) - 7) == input[8]

  z = (z * 26) + input[9] + 7 # 1-9 + 7 must be 14-22, so must be 7-9

  z /= 26
  # z mod 26 must be between 14-22: from input 9: 14-16 - 13 is 1-3
  return nil unless ((z % 26) - 13) == input[10]

  z /= 26
  # z mod 26 must be 1-9: (from input 4) is 7-9
  return nil unless (z % 26) == input[11]

  z /= 26
  # z mod 26 must be between 12-20: input 1 is 12-19 - 11: 1-8
  return nil unless ((z % 26) - 11) == input[12]

  z /= 26
  # z mod 26 must be 1-9, (1-9) + 1 means this must be 2-9
  return nil unless (z % 26) == input[13]

  z == 0
end

def choices(inputs)
  inputs[0].product(*inputs[1..])
end

def part1(input)
  code = translate(input)
  puts "-" * 10
  puts code.join("\n")
  puts "-" * 10
  eval code.join("\n")

  ranges = [
    (1..8).to_a, # 0, propagate to 13
    (2..9).to_a, # 1, propagate to 12
    [9], # 2, propagate to 3
    (1..3).to_a, # 4, propagate to 11
    (8..9).to_a, # 5, propagate to 8
    (1..4).to_a, # 6 propagate to 7
    (7..9).to_a, # 9, propagate to 10
  ]

  bar = progress_bar(title: "validating...")
  found = []
  ranges[0].product(*ranges[1..]) do |seq|
    expanded = [
      seq[0], # 0
      seq[1], # 1
      seq[2], # 2
      seq[2] - 8, # 3
      seq[3], # 4
      seq[4], # 5
      seq[5], # 6
      seq[5] + 5, # 7
      seq[4] - 7, # 8
      seq[6], # 9
      seq[6] - 6, # 10
      seq[3], # 11
      seq[1] - 1, # 12
      seq[0], # 13
    ]
    bar.advance
    puts "#{expanded} : #{monad(expanded)}"
    next unless monad(expanded) == 0

    puts expanded.to_s
    found << expanded
  end
  found
end

def translate(input)
  code = ["def monad(input)", "x = y = z = w = i = 0"]
  i = -1
  translated = input.lines.map do |line|
    case line
    when /inp (\w)/
      i += 1
      "\n#{$1} = input[#{i}]"
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
end

def part2(input)
  input.lines
end

part 1
with :part1
no_debug!
try puzzle_input

# part 2
# with :part2
# no_debug!
# try puzzle_input
