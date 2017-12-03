require_relative "../toolkit"

def repeated(input, times)
  times.times do
    input = look_and_say(input)
  end
  yield input
end

def look_and_say(input)
  out = []
  input.scan(/((\d)\2*)/).map(&:first).each do |group|
    out << group.length
    out << group[0]
  end
  out.join
end

part 1
with :look_and_say
try "1", "11"
try "11", "21"
try "21", "1211"
try "1211", "111221"
with(:repeated, 40) { |s| s.length }
try puzzle_input

part 2
with(:repeated, 50) { |s| s.length }
try puzzle_input
