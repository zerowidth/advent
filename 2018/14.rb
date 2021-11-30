require_relative "../toolkit"

class Integer
  def digits
    to_s.chars.map(&:to_i)
  end
end

def part1(input)
  num_recipes = input.numbers.first

  scoreboard = [3, 7]
  e0 = 0
  e1 = 1

  bar = progress_bar(total: num_recipes + 10, title: "making recipes") unless debug?
  loop do
    current = scoreboard[e0] + scoreboard[e1]
    if current == 10
      scoreboard.push(1)
      scoreboard.push(0)
      bar.advance 2 unless debug?
    elsif current > 10
      scoreboard.push(current / 10)
      scoreboard.push(current % 10)
      bar.advance 2 unless debug?
    else
      scoreboard.push(current % 10)
      bar.advance unless debug?
    end
    e0 = (e0 + scoreboard[e0] + 1) % scoreboard.length
    e1 = (e1 + scoreboard[e1] + 1) % scoreboard.length
    debug "#{scoreboard}" if debug?
    break if scoreboard.length >= (num_recipes + 10)
  end
  bar.finish unless debug?

  scoreboard.drop(num_recipes).take(10).join
end

# string version: faster, inclusion checks in particular
def part2(input)
  pattern = input.chomp

  scoreboard = "37"
  e0 = 0
  e1 = 1

  bar = progress_bar(title: "making recipes") unless debug?
  loop do
    current = scoreboard[e0].to_i + scoreboard[e1].to_i
    debug "current #{current}"
    digits = current.to_s
    scoreboard << digits
    unless debug?
      bar.advance scoreboard.length - bar.current if scoreboard.length % 10_000 == 0
    end
    e0 = (e0 + scoreboard[e0].to_i + 1) % scoreboard.length
    e1 = (e1 + scoreboard[e1].to_i + 1) % scoreboard.length
    debug scoreboard.chars.join(" ") if debug?

    # only need to check last one or two characters since we've only added one or two
    if scoreboard.length > pattern.length + 1
      break if scoreboard[(-pattern.length - 1)..].include?(pattern)
    elsif scoreboard.length > pattern.length
      break if scoreboard[-pattern.length..].include?(pattern)
    elsif scoreboard.include?(pattern)
      break
    end
  end
  bar.finish unless debug?

  scoreboard.index(pattern)
end

ex1 = "9"
ex2 = "5"
ex3 = "18"
ex4 = "2018"

part 1
with :part1
debug!
try ex1, expect: "5158916779"
try ex2, expect: "0124515891"
no_debug!
try ex3, expect: "9251071085"
try ex4, expect: "5941429882"
# try puzzle_input

part 2
with :part2
debug!
try "51589", expect: 9
try "01245", expect: 5
try "92510", expect: 18
no_debug!
try "59414", expect: 2018
no_debug!
try puzzle_input
