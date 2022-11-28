require_relative "../toolkit"

class Room
  def initialize(input)
    @input = input
  end

  def sector_id
    @input.split("-").last[/\d+/].to_i
  end

  def valid?
    parts = @input.split("-")
    raise unless parts.last =~ /\d+\[([a-z]+)\]/
    check = $1
    checksum = parts[0..-2].join.chars.tally.sort_by { |k, v| [-v, k] }.map(&:first).take(5).join
    dpp @input, checksum
    checksum == check
  end

  def decrypt
    string = @input.split("-")[0..-2].join
    alphabet = ("a".."z").to_a
    string.tr(alphabet.join, alphabet.rotate(sector_id).join)
  end
end

def part1(input)
  rooms = input.lines.map { |line| Room.new(line) }
  rooms.select(&:valid?).map(&:sector_id).sum
end

def part2(input)
  rooms = input.lines.map { |line| Room.new(line) }
  rooms.select(&:valid?).detect do |room|
    room.decrypt =~ /north/
  end&.sector_id
end

ex1 = <<EX
aaaaa-bbb-z-y-x-123[abxyz]
a-b-c-d-e-f-g-h-987[abcde]
not-a-real-room-404[oarel]
totally-real-room-200[decoy]
EX

part 1
with :part1
debug!
try ex1, (123+987+404)
no_debug!
try puzzle_input

part 2
with :part2
no_debug!
try puzzle_input
