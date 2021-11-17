require_relative "../toolkit"

def part1(input, turns:)
  # number => [turns when it was spoken]
  utterances = Hash.new { |h, k| h[k] = [] }
  last = nil

  numbers = input.numbers

  turns.times_with_progress do |turn|
    if turn < numbers.length
      last = numbers[turn]
      utterances[last] << turn + 1
      debug "turn #{turn + 1}: say #{last}"
      next
    end

    turn += 1
    spoken = utterances[last]
    case spoken.length
    when 0
      last = numbers[turn - 1]
      utterances[last] << turn
      utterances[last] = utterances[last].last(2)
      debug "turn #{turn}: say #{last} (first time)"
    when 1
      debug "turn #{turn}: #{last} was the first time, say 0" if $debug
      last = 0
      utterances[last] << turn
      utterances[last] = utterances[last].last(2)
    else
      prevprev, prev = *spoken
      last = prev - prevprev
      utterances[last] << turn
      utterances[last] = utterances[last].last(2)
      debug "turn #{turn}: say #{last}" if $debug
    end
  end

  last
end

ex0 = "0,3,6"
ex1 = "1,3,2"
ex2 = "2,1,3"
ex3 = "1,2,3"
ex4 = "2,3,1"
ex5 = "3,2,1"
ex6 = "3,1,2"

part 1

with :part1, turns: 10
debug!
try ex0, expect: 0

with :part1, turns: 2020
no_debug!
try ex1, expect: 1
try ex2, expect: 10
try ex3, expect: 27
try ex4, expect: 78
try ex5, expect: 438
try ex6, expect: 1836
try puzzle_input

part 2

with :part1, turns: 30000000
no_debug!
try ex0, expect: 175594
# try ex1, expect: 2578
# try ex2, expect: 3544142
# try ex3, expect: 261214
# try ex4, expect: 6895259
# try ex5, expect: 18
# try ex6, expect: 362
try puzzle_input
