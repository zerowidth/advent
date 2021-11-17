require_relative "../toolkit"

ex1 = <<-EX
939
7,13,x,x,59,x,31,19
EX

def part1(input)
  time, buses = *input.split("\n", 2)
  time = time.to_i
  buses = buses.strip.split(",").reject { |b| b == "x" }.map(&:to_i)
  earliest = buses.map do |bus|
    [bus, (time.to_f / bus).ceil * bus]
  end.min_by(&:last)
  earliest[0] * (earliest[1] - time)
end

def part2(input)
  departures = input.each_line.to_a.last.strip.split(",").map do |d|
    d == "x" ? d : d.to_i
  end

  # insights:
  # * all the numbers are coprime (GCD is 1, for all pairs)
  # * https://en.wikipedia.org/wiki/Diophantine_equation#System_of_linear_Diophantine_equations
  # * https://en.wikipedia.org/wiki/Smith_normal_form
  # * https://en.wikipedia.org/wiki/Chinese_remainder_theorem
  # * https://eli.thegreenplace.net/2020/computing-the-chinese-remainder-theorem/

  ns = departures.each.with_index.reject { |v, _| v == "x" }.map do |bus, delay|
    # if bus b leaves t+delay minutes after our target value, it's
    # (bus - delay) under (mod bus) arithmetic
    [bus, bus - delay]
  end

  # testing...
  # ns = [[7, 0], [13, 1], [59, 4], [31, 6], [19, 7]]
  # ns = [[5, 3], [7, 1], [8, 6]]
  # ns = [[77003, 2292], [61223, 3010], [60161, 500], [25873, 399]]
  # ns = [[3, 0], [4, 3], [5, 4]]
  debug ns.map { |n, a| "#{a} (mod #{n})"}.join(", ")
  raise "not coprime!" unless ns.map(&:first).combination(2).all? { |a, b| a.gcd(b) == 1 }

  big_n = ns.map(&:first).reduce(1, &:*)
  debug "N: #{big_n}"
  x = 0 # accumulated answer
  ns.each do |nk, a| # x is congruent to a (mod nk)
    debug "#{a} (mod #{nk})"
    # Nk = N/nk
    big_nk = big_n/nk
    debug "  Nk = #{big_n} / #{nk} = #{big_nk}"
    # N'k = inverse mod of Nk (mod nk)
    big_nk_prime = big_nk.inverse_mod(nk)
    debug "  Nk' = #{big_nk_prime} (mod #{nk})"
    # a * Nk * Nkp
    v = a * big_nk * big_nk_prime
    debug "  a * Nk * Nk' = #{a} * #{big_nk} * #{big_nk_prime} = #{v} (mod #{big_n})"
    x += v
  end
  debug "x = #{x} (mod #{big_n}) = #{x % big_n}"
  x % big_n
end

part 1
with :part1
try ex1, expect: 295
try puzzle_input

part 2
with :part2
debug!
# try "17,x,13,19", 3417
no_debug!
try "67,7,59,61", 754018
try "67,x,7,59,61", 779210
try puzzle_input
