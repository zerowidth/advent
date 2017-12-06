require_relative "../toolkit"
require "set"

def reallocate(input, loop_size = false)
  blocks = input.split(/\s+/).map(&:to_i)
  seen = Hash.new(0)
  cycles = 0

  loop do
    cycles += 1
    # puts "cycle #{cycles} blocks: #{(blocks).inspect}"
    sorted_by_size = blocks.map.with_index.sort_by { |b, i| [-b, i] }
    i = sorted_by_size.shift.last
    to_distribute = blocks[i]
    blocks[i] = 0
    while to_distribute > 0
      i = (i + 1) % blocks.length
      blocks[i] += 1
      to_distribute -= 1
    end
    break if seen.key?(blocks)
    seen[blocks] = cycles
  end

  if loop_size
    cycles - seen[blocks]
  else
    cycles
  end
end

part 1
with(:reallocate, false)
try "0 2 7 0", 5
try puzzle_input

part 2
with(:reallocate, true)
try "0 2 7 0", 4
try puzzle_input
