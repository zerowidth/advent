require_relative "../toolkit"

def part1(input)
  bits = [input].pack("H*").unpack1("B*").digits
  versions = parse_versions(bits)
  debug "versions: #{versions}"
  versions.sum
end

def part2(input)
  bits = [input].pack("H*").unpack1("B*").digits
  interpret(bits)
end

def decode(bits)
  bits.join.to_i(2)
end

def parse_versions(bits)
  version = decode(bits.shift(3))
  debug "version #{version}"
  type = decode(bits.shift(3))
  debug "type: #{type}"

  versions = [version]

  case type
  when 4 # literal value
    num = []
    loop do
      part = bits.shift(5)
      debug "  shifted #{part}"
      num.concat part.drop(1)
      break if part.first.zero? || bits.empty?
    end
    num = num.join.to_i(2)
    debug "literal num: #{num}"
  else # some kind of operator
    length_type_id = decode([bits.shift])
    debug "length_type_id: #{length_type_id}"
    case length_type_id
    when 0
      # get next 15 bits, number of bits in subpackets
      length = decode(bits.shift(15))
      debug "subpacket bits: #{length}"
      subpacket = bits.shift(length)
      until subpacket.empty?
        debug "parsing subpacket"
        versions.concat parse_versions(subpacket)
      end
    when 1
      # next 11 bits are number of sub-packets contained
      count = decode(bits.shift(11))
      debug "subpacket count: #{count}"
      count.times do |n|
        debug "parsing subpacket #{n}"
        versions.concat parse_versions(bits)
      end
    else
      raise "wtf length type id #{length_type_id}"
    end
  end
  versions
end

def subpackets(bits)
  values = []
  length_type_id = decode([bits.shift])
  debug "length_type_id: #{length_type_id}"
  case length_type_id
  when 0
    # get next 15 bits, number of bits in subpackets
    length = decode(bits.shift(15))
    debug "subpacket bits: #{length}"
    subpacket = bits.shift(length)
    until subpacket.empty?
      debug "parsing subpacket"
      values << interpret(subpacket)
    end
  when 1
    # next 11 bits are number of sub-packets contained
    count = decode(bits.shift(11))
    debug "subpacket count: #{count}"
    count.times do |n|
      debug "parsing subpacket #{n}"
      values << interpret(bits)
    end
  else
    raise "wtf length type id #{length_type_id}"
  end
  values
end

def interpret(bits)
  version = decode(bits.shift(3))
  debug "version #{version}"
  type = decode(bits.shift(3))
  debug "type: #{type}"

  case type
  when 0 # sum
    values = subpackets(bits)
    debug "sum of #{values}"
    values.sum
  when 1 # product
    values = subpackets(bits)
    debug "product of #{values}"
    values.reduce(&:*)
  when 2 # minimum
    values = subpackets(bits)
    debug "minimum of #{values}"
    values.min
  when 3 # maximum
    values = subpackets(bits)
    debug "maximum of #{values}"
    values.max
  when 4 # literal value
    num = []
    loop do
      part = bits.shift(5)
      num.concat part.drop(1)
      break if part.first.zero? || bits.empty?
    end
    num = num.join.to_i(2)
    debug "literal num: #{num}"
    num
  when 5 # greater than
    values = subpackets(bits)
    debug "greater than #{values}"
    values.first > values.last ? 1 : 0
  when 6 # less than
    values = subpackets(bits)
    debug "less than #{values}"
    values.first < values.last ? 1 : 0
  when 7 # equal to
    values = subpackets(bits)
    debug "equal #{values}"
    values.first == values.last ? 1 : 0
  end
end

ex1 = "D2FE28"
ex2 = "38006F45291200"
ex3 = "EE00D40C823060"
ex4 = "8A004A801A8002F478"

ex5 = "C200B40A82"
ex6 = "9C0141080250320F1802104A08"

part 1
with :part1
debug!
try ex1, 6
try ex2, 9
try ex3, 14
try ex4, 16
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex5, 3
try ex6, 1
no_debug!
try puzzle_input
