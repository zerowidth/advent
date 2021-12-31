require_relative "../toolkit"

def monad(input)
  x = y = z = 0

  w = input[0] # inp w
  x = x * 0 # mul x 0
  x = x + z # add x z
  x = x % 26 # mod x 26
  z = z / 1 # div z 1
  x = x + 11 # add x 11
  x = x == w ? 1 : 0 # eql x w
  x = x == 0 ? 1 : 0 # eql x 0
  y = y * 0 # mul y 0
  y = y + 25 # add y 25
  y = y * x # mul y x
  y = y + 1 # add y 1
  z = z * y # mul z y
  y = y * 0 # mul y 0
  y = y + w # add y w
  y = y + 1 # add y 1
  y = y * x # mul y x
  z = z + y # add z y

  w = input[1] # inp w
  x = x * 0 # mul x 0
  x = x + z # add x z
  x = x % 26 # mod x 26
  z = z / 1 # div z 1
  x = x + 10 # add x 10
  x = x == w ? 1 : 0 # eql x w
  x = x == 0 ? 1 : 0 # eql x 0
  y = y * 0 # mul y 0
  y = y + 25 # add y 25
  y = y * x # mul y x
  y = y + 1 # add y 1
  z = z * y # mul z y
  y = y * 0 # mul y 0
  y = y + w # add y w
  y = y + 10 # add y 10
  y = y * x # mul y x
  z = z + y # add z y

  w = input[2] # inp w
  x = x * 0 # mul x 0
  x = x + z # add x z
  x = x % 26 # mod x 26
  z = z / 1 # div z 1
  x = x + 13 # add x 13
  x = x == w ? 1 : 0 # eql x w
  x = x == 0 ? 1 : 0 # eql x 0
  y = y * 0 # mul y 0
  y = y + 25 # add y 25
  y = y * x # mul y x
  y = y + 1 # add y 1
  z = z * y # mul z y
  y = y * 0 # mul y 0
  y = y + w # add y w
  y = y + 2 # add y 2
  y = y * x # mul y x
  z = z + y # add z y

  w = input[3] # inp w
  x = x * 0 # mul x 0
  x = x + z # add x z
  x = x % 26 # mod x 26
  z = z / 26 # div z 26
  x = x + -10 # add x -10
  x = x == w ? 1 : 0 # eql x w
  x = x == 0 ? 1 : 0 # eql x 0
  y = y * 0 # mul y 0
  y = y + 25 # add y 25
  y = y * x # mul y x
  y = y + 1 # add y 1
  z = z * y # mul z y
  y = y * 0 # mul y 0
  y = y + w # add y w
  y = y + 5 # add y 5
  y = y * x # mul y x
  z = z + y # add z y

  w = input[4] # inp w
  x = x * 0 # mul x 0
  x = x + z # add x z
  x = x % 26 # mod x 26
  z = z / 1 # div z 1
  x = x + 11 # add x 11
  x = x == w ? 1 : 0 # eql x w
  x = x == 0 ? 1 : 0 # eql x 0
  y = y * 0 # mul y 0
  y = y + 25 # add y 25
  y = y * x # mul y x
  y = y + 1 # add y 1
  z = z * y # mul z y
  y = y * 0 # mul y 0
  y = y + w # add y w
  y = y + 6 # add y 6
  y = y * x # mul y x
  z = z + y # add z y

  w = input[5] # inp w
  x = x * 0 # mul x 0
  x = x + z # add x z
  x = x % 26 # mod x 26
  z = z / 1 # div z 1
  x = x + 11 # add x 11
  x = x == w ? 1 : 0 # eql x w
  x = x == 0 ? 1 : 0 # eql x 0
  y = y * 0 # mul y 0
  y = y + 25 # add y 25
  y = y * x # mul y x
  y = y + 1 # add y 1
  z = z * y # mul z y
  y = y * 0 # mul y 0
  y = y + w # add y w
  y = y + 0 # add y 0
  y = y * x # mul y x
  z = z + y # add z y

  w = input[6] # inp w
  x = x * 0 # mul x 0
  x = x + z # add x z
  x = x % 26 # mod x 26
  z = z / 1 # div z 1
  x = x + 12 # add x 12
  x = x == w ? 1 : 0 # eql x w
  x = x == 0 ? 1 : 0 # eql x 0
  y = y * 0 # mul y 0
  y = y + 25 # add y 25
  y = y * x # mul y x
  y = y + 1 # add y 1
  z = z * y # mul z y
  y = y * 0 # mul y 0
  y = y + w # add y w
  y = y + 16 # add y 16
  y = y * x # mul y x
  z = z + y # add z y

  w = input[7] # inp w
  x = x * 0 # mul x 0
  x = x + z # add x z
  x = x % 26 # mod x 26
  z = z / 26 # div z 26
  x = x + -11 # add x -11
  x = x == w ? 1 : 0 # eql x w
  x = x == 0 ? 1 : 0 # eql x 0
  y = y * 0 # mul y 0
  y = y + 25 # add y 25
  y = y * x # mul y x
  y = y + 1 # add y 1
  z = z * y # mul z y
  y = y * 0 # mul y 0
  y = y + w # add y w
  y = y + 12 # add y 12
  y = y * x # mul y x
  z = z + y # add z y

  w = input[8] # inp w
  x = x * 0 # mul x 0
  x = x + z # add x z
  x = x % 26 # mod x 26
  z = z / 26 # div z 26
  x = x + -7 # add x -7
  x = x == w ? 1 : 0 # eql x w
  x = x == 0 ? 1 : 0 # eql x 0
  y = y * 0 # mul y 0
  y = y + 25 # add y 25
  y = y * x # mul y x
  y = y + 1 # add y 1
  z = z * y # mul z y
  y = y * 0 # mul y 0
  y = y + w # add y w
  y = y + 15 # add y 15
  y = y * x # mul y x
  z = z + y # add z y

  w = input[9] # inp w
  x = x * 0 # mul x 0
  x = x + z # add x z
  x = x % 26 # mod x 26
  z = z / 1 # div z 1
  x = x + 13 # add x 13
  x = x == w ? 1 : 0 # eql x w
  x = x == 0 ? 1 : 0 # eql x 0
  y = y * 0 # mul y 0
  y = y + 25 # add y 25
  y = y * x # mul y x
  y = y + 1 # add y 1
  z = z * y # mul z y
  y = y * 0 # mul y 0
  y = y + w # add y w
  y = y + 7 # add y 7
  y = y * x # mul y x
  z = z + y # add z y

  w = input[10] # inp w
  x = x * 0 # mul x 0
  x = x + z # add x z
  x = x % 26 # mod x 26
  z = z / 26 # div z 26
  x = x + -13 # add x -13
  x = x == w ? 1 : 0 # eql x w
  x = x == 0 ? 1 : 0 # eql x 0
  y = y * 0 # mul y 0
  y = y + 25 # add y 25
  y = y * x # mul y x
  y = y + 1 # add y 1
  z = z * y # mul z y
  y = y * 0 # mul y 0
  y = y + w # add y w
  y = y + 6 # add y 6
  y = y * x # mul y x
  z = z + y # add z y

  w = input[11] # inp w
  x = x * 0 # mul x 0
  x = x + z # add x z
  x = x % 26 # mod x 26
  z = z / 26 # div z 26
  x = x + 0 # add x 0
  x = x == w ? 1 : 0 # eql x w
  x = x == 0 ? 1 : 0 # eql x 0
  y = y * 0 # mul y 0
  y = y + 25 # add y 25
  y = y * x # mul y x
  y = y + 1 # add y 1
  z = z * y # mul z y
  y = y * 0 # mul y 0
  y = y + w # add y w
  y = y + 5 # add y 5
  y = y * x # mul y x
  z = z + y # add z y

  w = input[12] # inp w
  x = x * 0 # mul x 0
  x = x + z # add x z
  x = x % 26 # mod x 26
  z = z / 26 # div z 26
  x = x + -11 # add x -11
  x = x == w ? 1 : 0 # eql x w
  x = x == 0 ? 1 : 0 # eql x 0
  y = y * 0 # mul y 0
  y = y + 25 # add y 25
  y = y * x # mul y x
  y = y + 1 # add y 1
  z = z * y # mul z y
  y = y * 0 # mul y 0
  y = y + w # add y w
  y = y + 6 # add y 6
  y = y * x # mul y x
  z = z + y # add z y

  w = input[13] # inp w
  x = x * 0 # mul x 0
  x = x + z # add x z
  x = x % 26 # mod x 26
  z = z / 26 # div z 26
  x = x + 0 # add x 0
  x = x == w ? 1 : 0 # eql x w
  x = x == 0 ? 1 : 0 # eql x 0
  y = y * 0 # mul y 0
  y = y + 25 # add y 25
  y = y * x # mul y x
  y = y + 1 # add y 1
  z = z * y # mul z y
  y = y * 0 # mul y 0
  y = y + w # add y w
  y = y + 15 # add y 15
  y = y * x # mul y x
  z = z + y # add z y
  z
end

def valid?(input)
  z = 0
  z = (z * 26) + input[0] + 1
  # z = i0 + 1

  z = (z * 26) + input[1] + 10
  # z = (i0 + 1) * 26 + i1 + 10

  z = (z * 26) + input[2] + 2
  # z = ((i0 + 1) * 26 + i1 + 10) * 26 + i2 + 2

  x = (z % 26) - 10
  # x = i2 + 2 - 10
  z /= 26
  # z = (i0 + 1) * 26 + i1 + 10
  return nil unless x == input[3]

  z = (z * 26) + input[4] + 6
  # z = ((i0 + 1) * 26 + i1 + 10) * 26 + i4 + 6

  z = (z * 26) + input[5] + 0
  # z = (((i0 + 1) * 26 + i1 + 10) * 26 + i4 + 6) * 26 + i5 + 0

  z = (z * 26) + input[6] + 16
  # z = ((((i0 + 1) * 26 + i1 + 10) * 26 + i4 + 6) * 26 + i5 + 0) * 26 + i6 + 16

  x = (z % 26) - 11
  # x = i6 + 16 - 11
  z /= 26
  # z = (((i0 + 1) * 26 + i1 + 10) * 26 + i4 + 6) * 26 + i5 + 0
  return nil unless x == input[7]

  x = (z % 26) + 7
  # x = i5 + 0 + 7
  z /= 26
  # z = ((i0 + 1) * 26 + i1 + 10) * 26 + i4 + 6
  return nil unless x == input[8]

  z = (z * 26) + input[9] + 7
  # z = (((i0 + 1) * 26 + i1 + 10) * 26 + i4 + 6) * 26 + i9 + 7

  x = (z % 26) - 13
  # x = i9 + 7 - 13
  z /= 26
  # z = ((i0 + 1) * 26 + i1 + 10) * 26 + i4 + 6
  return nil unless x == input[10]

  x = (z % 26) + 0
  # x = i4 + 6
  z /= 26
  # z = (i0 + 1) * 26 + i1 + 10
  return nil unless x == input[11]

  x = (z % 26) - 11
  # x = i1 + 10
  z /= 26
  # z = i0 + 1
  return nil unless x == input[12]

  x = (z % 26) + 0
  # x = i0 + 1
  z /= 26
  # z = 0
  return nil unless x == input[13]

  z
end

def get_ranges(input)
  sections = input.split("inp w").drop(1)
  ranges = Array.new(sections.length)
  adds = []

  # debug { "z = 0" }
  sections.map { |s| Input.new(s.strip).lines }.each_with_index do |lines, i|
    case lines[3]
    when "div z 1" # multiplying z
      adding = lines[14].signed_numbers.first
      # debug { "z = (z * 26) + input[#{i}] + #{adding}" }
      adds << [adding, i]
    when "div z 26" # reducing z
      subtracting = lines[4].signed_numbers.first
      # debug { "x = (z % 26) - #{subtracting.abs}\nz /= 26\nreturn nil unless x == input[#{i}]" }

      # we know:
      #   z = (whatever) * 26 + some input + some addition
      #   x = (some input + some addition) - subtraction
      # given:
      #   z = (z * 26) + input[1] + 10
      #   x = (z % 26) - 11
      #   return nil unless x == input[12]
      # we know that input[1] + 10 - 11 == input[12], or: input[12] = input[1] - 1
      add, addi = adds.pop
      diff = add + subtracting
      xrange = (1..9).map { |r| r + diff } & (1..9).to_a
      arange = (1..9).map { |r| r - diff } & (1..9).to_a
      debug { "  input[#{i}]: #{xrange}" }
      debug { "  input[#{addi}]: #{arange}" }
      ranges[i] = xrange
      ranges[addi] = arange
    else
      raise "wtf: #{lines[3]}"
    end
    # debug
  end
  # debug { "z" }

  ranges
end

def part1(input)
  get_ranges(input).map(&:last).map(&:to_s).join
end

def part2(input)
  get_ranges(input).map(&:first).map(&:to_s).join
end

def translate(input)
  code = ["def monad(input)", "x = y = z = w = 0"]
  i = -1
  translated = input.lines.map do |line|
    case line
    when /inp (\w)/
      i += 1
      "\n#{$1} = input[#{i}] # #{line}"
    when /add (\w) (-?\d+|\w)/
      "#{$1} = #{$1} + #{$2} # #{line}"
    when /mul (\w) (-?\d+|\w)/
      "#{$1} = #{$1} * #{$2} # #{line}"
    when /div (\w) (-?\d+|\w)/
      "#{$1} = #{$1} / #{$2} # #{line}"
    when /mod (\w) (-?\d+|\w)/
      "#{$1} = #{$1} % #{$2} # #{line}"
    when /eql (\w) (-?\d+|\w)/
      "#{$1} = #{$1} == #{$2} ? 1 : 0 # #{line}"
    else
      raise "what #{line}"
    end
  end
  code.concat translated
  code << "z"
  code << "end"
end

part 1
with :part1
debug!
# no_debug!
try puzzle_input

part 2
with :part2
# no_debug!
try puzzle_input
