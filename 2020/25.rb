require_relative "../toolkit"

def transform(subject_number, loop_size)
  value = 1
  loop_size.times do
    value = (value * subject_number) % 20201227
  end
  value
end

def loop_size(public_key, subject:)
  public_key = public_key.to_i
  value = 1
  loop_size = 1
  loop do
    value = (value * subject) % 20201227
    break if value == public_key
    loop_size += 1
  end
  loop_size
end

def part1(input)
  card_pubkey = input.lines.first
  door_pubkey = input.lines.last
  card_loop_size = loop_size(card_pubkey, subject: 7)

  transform(door_pubkey.to_i, card_loop_size)
end

ex1 = <<-EX
5764801
EX

ex2 = "17807724"

ex3 = <<EX
5764801
17807724
EX

part 1
debug!
with :loop_size, subject: 7
try ex1, expect: 8
try ex2, expect: 11

with :part1
try ex3, expect: 14897079

no_debug!
try puzzle_input

# part 2
# with :part2
# debug!
# try ex1, expect: nil
# no_debug!
# try puzzle_input
