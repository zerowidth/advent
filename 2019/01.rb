require_relative "../toolkit"

def weight(i)
  [i / 3 - 2, 0].max
end

def weight_sum(input)
  input.split.map(&:strip).map(&:to_i).map_with(:weight).sum
end

def weight_recursive(input)
  input.split.map(&:strip).map(&:to_i).map do |w|
    total = 0
    loop do
      part = weight(w)
      break if part == 0
      total += part
      w = part
    end
    total
  end.sum
end

ex1 = <<-EX
12
EX

ex2 = <<-EX
14
EX

ex3 = <<-EX
1969
EX

ex4 = <<-EX
100756
EX

part 1
with(:weight_sum)
try ex1, 2
try ex2, 2
try ex3, 654
try ex4, 33583
try puzzle_input

part 2
with(:weight_recursive)
try "14", 2
try "1969", 966
try puzzle_input
