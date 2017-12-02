require_relative "../toolkit"

def sum_with_matching_offset(input, &block)
  list = input.digits
  offset = yield list
  list.zip(list.rotate(offset)).select { |a, b| a == b }.map(&:first).sum
end

with(:sum_with_matching_offset) { 1 }
try "1122", 3
try "1111", 4
try "1234", 0
try "91212129", 9
try puzzle_input

with(:sum_with_matching_offset) { |list| list.length / 2 }
try "1212", 6
try "1221", 0
try "123425", 4
try "123123", 12
try puzzle_input
