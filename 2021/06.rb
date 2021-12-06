require_relative "../toolkit"

# fish takes 7 days, number is its age
# new fish takes 9 days

def part1(input, days:)
  fish = Hash.new(0)
  input.numbers.each { |f| fish[f] += 1 }
  days.times do
    next_fish = Hash.new(0)
    fish.each do |t, c|
      if t.zero?
        next_fish[8] += c
        next_fish[6] += c
      else
        next_fish[t - 1] += c
      end
    end
    fish = next_fish
  end
  fish.values.sum
end

def part2(input)
  input.lines
  nil
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
