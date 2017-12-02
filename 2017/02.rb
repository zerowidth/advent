require_relative "../toolkit"

def checksum(input, &block)
  input.number_table.map(&block).sum
end

s = <<-S
5 1 9 5
7 5 3
2 4 6 8
S

with(:checksum) { |row| row.max - row.min }
try s, 18
try puzzle_input

with(:checksum) do |row|
  # evenly divides means mod is 0
  sum = 0
  row.each do |i|
    row.each do |j|
      if i > j && i % j == 0
        sum += (i / j)
      end
    end
  end
  sum
end

t = <<-T
5 9 2 8
9 4 7 3
3 8 6 5
T

try t, 9
try puzzle_input
