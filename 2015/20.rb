require_relative "../toolkit"
require "prime"

def aliquot(num)
  # aliquot sum https://www.geeksforgeeks.org/aliquot-sum/
  debug "gifts for #{num}"
  divisors = Prime.prime_division(num)
  debug "  divisors: #{divisors.inspect}"
  factors = divisors.map do |base, exponent|
    0.upto(exponent).map { |e| base**e }
  end
  debug "  factors: #{factors.inspect}"
  sums = factors.map(&:sum)
  debug "  sums: #{sums}"
  sum = sums.reduce(1, &:*)
  debug "  sum: #{sum}"
  sum
end

def factors(num)
  return [1] if num == 1

  debug "factors for #{num}"
  divisors = Prime.prime_division(num)
  debug "  prime divisors: #{divisors.inspect}"
  factors = divisors.map do |base, exponent|
    0.upto(exponent).map { |e| base**e }
  end
  products = factors.length == 1 ? factors.first : factors.first.product(*factors[1..]).map { |f| f.reduce(1, &:*) }
  debug "  products: #{products}"
  products.sort
end

def lazy_visits(num, limit)
  debug "lazy for #{num}"
  fs = factors(num)
  fs.select { |n| num / n <= limit }.sum
end

def part1(input)
  target = input.to_i
  1.upto(target).each_with_progress do |house|
    sum = aliquot(house) * 10
    debug "house #{house} gifts #{sum}"
    break house if sum >= target
  end
end

def part2(input)
  target = input.to_i
  1.upto(target).each_with_progress do |house|
    sum = lazy_visits(house, 50) * 11
    debug "house #{house} gifts #{sum}"
    break house if sum >= target
  end
end

part 1
with :part1
debug!
try "70", expect: 4
try "150", expect: 8
no_debug!
# try puzzle_input

part 2

# with :factors
# debug!
# try 1, expect: [1]
# try 2, expect: [1, 2]
# try 3, expect: [1, 3]
# try 4, expect: [1, 2, 4]
# try 12, expect: [1, 2, 3, 4, 6, 12]
# try 30, expect: [1, 2, 3, 5, 6, 10, 15, 30]
# try 60, expect: [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60]

# with :lazy_visits, 5
# debug!
# try 1, expect: 1
# try 2, expect: 3
# try 3, expect: 4
# try 4, expect: 7 # 1x4, 2x2, 4x1
# try 5, expect: 6 # 1x1, 1x5
# try 6, expect: 11 # 0x2, 1x2, 1x3, 1x6
# try 7, expect: 7 # n=1 exceeded
# try 8, expect: 14 # n=1 exceeded
# try 9, expect: 12 # n=1 exceeded
# try 10, expect: 17 # n=1 exceeded
# try 11, expect: 11 # n=1 exceeded
# try 12, expect: 28 - 1 - 2 # 0x1 + 0x2 + 1x3 + 1x4 + 1x6 + 1x12
# try 30, expect: 61 # 6 + 10 + 15 + 30

with :part2
no_debug!
try puzzle_input
