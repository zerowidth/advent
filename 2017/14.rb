require_relative "../toolkit"

def knot_hash_binary(input)
  list = (0...256).to_a
  pos = 0
  skip = 0
  lengths = input.chars.map(&:ord) + [17, 31, 73, 47, 23]

  64.times do
    lengths.each do |len|
      list = list.rotate(pos)
      reversed = list[0...len].reverse
      0.upto(len - 1) { |i| list[i] = reversed[i] }
      list = list.rotate(-pos)
      pos = ((pos + len) + skip) % 256
      skip += 1
    end
  end

  hashed = list.each_slice(16).map { |block| block.inject(&:^) }
  hashed.pack("C*").unpack("B*")[0].chars.map(&:to_i)
end

@bits ||= {}
def bits(input)
  @bits.fetch(input) do
    0.upto(127).with_progress(total: 128).map do |n|
      knot_hash_binary("#{input}-#{n}")
    end
  end
end

def part1(input)
  bits(input).flatten.group_by { |c| c }[1].size
end

def part2(input)
  count_islands(bits(input))
end

def count_islands(bits, debug: false)
  land = Set.new
  w = bits.first.size
  bits.each.with_index do |row, y|
    row.each.with_index do |bit, x|
      land << (x + y * w) if bit == 1
    end
  end

  display(land, w) if debug

  regions = {}
  count = 0
  until land.empty?
    region = Set.new [land.first]
    q = [land.first]
    until q.empty?
      p = q.shift
      land.delete p
      neighbors(p, w).each do |n|
        # [p-1, p+1, p-w, p+w].each do |n|
        if land.include?(n) && !region.include?(n)
          q << n
          region << n
        end
      end
    end
    regions[count] = region
    count += 1
    display(land, w, region) if debug
  end

  regions.size
end

def neighbors(p, w)
  ns = []
  ns << (p - 1) if p % w > 0
  ns << (p + 1) if (p + 1) % w > 0
  ns << p - w if p >= w
  ns << p + w
  ns
end

def display(land, size, region = nil)
  puts "-" * size
  0.upto(size - 1) do |y|
    0.upto(size - 1) do |x|
      if region&.include?(x + y * size)
        print "▓▓".red
      elsif land.include?(x + y * size)
        print "▓▓"
      else
        print "░░"
      end
    end
    puts
  end
end

ex1 = "flqrgnkx"

part 1
with(:part1)
try puzzle_input

part 2
with(:count_islands, debug: true)
example_bits = bits(ex1)
example = example_bits[0..7].map { |s| s[0..7] }
try example, 12

with :part2
try ex1, 1242
try puzzle_input
