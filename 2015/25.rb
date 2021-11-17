require_relative "../toolkit"

# iterate from value, adding an increasing increment
def iterate_ascending(value, increment)
  Enumerator.new do |y|
    loop do
      y << value
      value += increment
      increment += 1
    end
  end.lazy
end

def number_at(row, col)
  # down the column: increment by 1, then 2, then 3, then 4
  # thus: 1, 2, 4, 7, 11
  # across the row: 1, increment: 2, then 3, then 4, then 5
  # thus: 1, 3, 6, 10, 15
  # but each subsequent row has a starting increment 1 greater
  # row 2 increments across with 3, 4, 5...
  debug "getting number for row #{row} col #{col}"
  row_start = iterate_ascending(1, 1).drop(row - 1).first
  debug "row start value: #{row_start}, increments #{1 + row}"
  debug "row: #{iterate_ascending(row_start, 1 + col).take(5).map(&:to_s).to_a.join(", ")}..."
  iterate_ascending(row_start, 1 + row).drop(col - 1).first
end

def part1(input)
  raise "wtf" unless input =~ /row (\d+), column (\d+)/

  row = $1.to_i
  col = $2.to_i

  iterations = number_at(row, col)
  puts "calculating row #{row}, col #{col}: need #{iterations} iterations"

  value = 20151125
  (iterations - 1).times do |n|
     value = (value * 252533) % 33554393
  end
  value
end

=begin
simple:
   | 1   2   3   4   5   6
---+---+---+---+---+---+---+
 1 |  1   3   6  10  15  21
 2 |  2   5   9  14  20
 3 |  4   8  13  19
 4 |  7  12  18
 5 | 11  17
 6 | 16

real one:
   |    1         2         3         4         5         6
---+---------+---------+---------+---------+---------+---------+
 1 | 20151125  18749137  17289845  30943339  10071777  33511524
 2 | 31916031  21629792  16929656   7726640  15514188   4041754
 3 | 16080970   8057251   1601130   7981243  11661866  16474243
 4 | 24592653  32451966  21345942   9380097  10600672  31527494
 5 |    77061  17552253  28094349   6899651   9250759  31663883
 6 | 33071741   6796745  25397450  24659492   1534922  27995004
=end

part 1
with :number_at
debug!
try 1, 1, expect: 1
try 1, 4, expect: 10
try 6, 1, expect: 16
try 2, 2, expect: 5
try 4, 3, expect: 18
no_debug!

with :part1
try "row 1, column 1", expect: 20151125
try "row 6, column 1", expect: 33071741
try "row 6, column 4", expect: 24659492
try puzzle_input

# there is no part 2