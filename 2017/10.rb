require_relative "../toolkit"

def knot_hash(input, length, rounds = 1, extra = [])
  list = (0...length).to_a
  pos = 0
  skip = 0

  lengths = input.split(/,\s*/).map(&:to_i)
  lengths.each do |len|
    # puts "list #{list.join(", ")} len: #{len}"
    # operate on the front of the list
    list = list.rotate(pos)

    reversed = list[0...len].reverse
    0.upto(len-1) { |i| list[i] = reversed[i] }

    # now put the list back
    list = list.rotate(-pos)
    pos = (pos + len) % length + skip
    skip += 1
  end

  block_given? ? yield(list) : list
end

def knot_hash_hex(input)
  list = (0...256).to_a
  pos = 0
  skip = 0
  lengths = input.chars.map(&:ord) + [17, 31, 73, 47, 23]

  64.times do
    lengths.each do |len|
      list = list.rotate(pos)
      reversed = list[0...len].reverse
      0.upto(len-1) { |i| list[i] = reversed[i] }
      list = list.rotate(-pos)
      pos = ((pos + len) + skip) % 256
      skip += 1
    end
  end

  hashed = list.each_slice(16).map { |block| block.inject(&:^) }
  hashed.pack("C*").unpack("H*")[0]
end

part 1
with(:knot_hash, 5) { |list| a, b = *list.first(2); a * b }
try "3, 4, 1, 5", 12
with(:knot_hash, 256) { |list| a, b = *list.first(2); a * b }
try puzzle_input

part 2
with(:knot_hash_hex)
try "", "a2582a3a0e66e6e86e3812dcb672a272"
try "AoC 2017", "33efeb34ea91902bb2f59c9920caa6cd"
try "1,2,3", "3efbe78a8d82f29979031a4aa0b16a9d"
try "1,2,4", "63960835bcdc130f0b66d7ff4f6a5a8e"
try puzzle_input
