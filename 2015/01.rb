require_relative "../toolkit"

def floor(input)
  input.each_char.inject(0) { |s, o| s += o == "(" ? 1 : -1 }
end

def basement(input)
  input.each_char.with_index.inject(0) do |sum, pair|
    op, i = *pair
    sum += op == "(" ? 1 : -1
    if sum < 0
      return i + 1
    end
    sum
  end
  nil
end

with :floor
try "(())", 0
try "()()", 0
try "))(((((", 3
try ")())())", -3
try puzzle_input

with :basement
try ")", 1
try "()())", 5
try puzzle_input
