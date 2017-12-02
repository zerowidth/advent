require_relative "../toolkit"
require "digest/md5"

def advent_coin(input, zeros)
  regex = Regexp.new("^" + "0" * zeros)
  i = 0
  loop do
    if Digest::MD5.hexdigest("#{input}#{i}") =~ regex
      return i
    end
    i += 1
  end
end

with :advent_coin, 5
try "abcdef", 609043
try "pqrstuv", 1048970
try puzzle_input

with :advent_coin, 6
try puzzle_input
