require_relative "../toolkit"

ex1 = <<-EX
1-3 a: abcde
1-3 b: cdefg
2-9 c: ccccccccc
EX

def part1(input)
  count = 0
  input.each_line do |line|
    line.scan(/(\d+)-(\d+) ([a-z]): (\w+)/) do |a, b, char, pass|
      count += 1 if (a.to_i..b.to_i).include?(pass.count(char))
    end
  end
  count
end

def part2(input)
  count = 0
  input.each_line do |line|
    line.scan(/(\d+)-(\d+) ([a-z]): (\w+)/) do |a, b, char, pass|
      a = a.to_i - 1
      b = b.to_i - 1
      if (pass[a] == char && pass[b] != char) || (pass[a] != char && pass[b] == char)
        # puts "#{pass} is valid: #{pass[a]} #{pass[b]} - #{char}"
        count += 1
      end
    end
  end
  count
end


part 1
with :part1
try ex1, expect: 2
try puzzle_input

part 2
with :part2
try ex1, expect: 1
try puzzle_input
