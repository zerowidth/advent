require_relative "../toolkit"

def part1(input, days:)
  fish = Hash.new(0)
  input.numbers.each { |f| fish[f] += 1 }
  days.times do
    fish = fish.each_with_object(Hash.new(0)) do |(t, count), next_fish|
      if t.zero?
        next_fish[8] += count
        next_fish[6] += count
      else
        next_fish[t - 1] += count
      end
    end
  end
  fish.values.sum
end

ex1 = <<EX
3,4,3,1,2
EX

part 1
debug!
with :part1, days: 18
try ex1, 26
with :part1, days: 80
try ex1, 5934
no_debug!
try puzzle_input

part 2
with :part1, days: 256
debug!
try ex1, 26984457539
no_debug!
try puzzle_input
