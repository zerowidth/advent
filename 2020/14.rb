require_relative "../toolkit"

def part1(input)
  memory = {}
  and_mask = 2**36 - 1
  or_mask = 0

  input.each_line.map(&:strip).map do |line|
    case line
    when /mask = (\w+)/
      mask = $1
      or_mask = mask.gsub(/[0X]/, "0").to_i(2)
      and_mask = mask.gsub(/[1X]/, "1").to_i(2)
      debug "loading mask #{mask}"
      debug "  or mask    #{or_mask.to_s(2).rjust(36, "0")}"
      debug "  and mask   #{and_mask.to_s(2)}"
    when /mem\[(\d+)\] = (\d+)/
      address = $1.to_i
      value = $2.to_i
      masked = value & and_mask | or_mask
      debug "writing #{value} (masked: #{masked} to #{address}"
      memory[address] = masked
    else
      raise "wtf"
    end
  end

  memory.values.sum
end

def part2(input)
  memory = {}
  mask = ""

  input.each_line.map(&:strip).map do |line|
    case line
    when /mask = (\w+)/
      mask = $1
      debug "set mask to #{mask}"
    when /mem\[(\d+)\] = (\d+)/
      address = $1.to_i
      value = $2.to_i
      debug "write #{value} to #{address}"
      debug "mask:    #{mask}"

      bits = mask.reverse.indices("X").to_a
      # debug "  indeterminate bits: #{bits.inspect}"
      raise "NO INDETERMINATE BITS" unless bits.any?

      # 0's should be unchanged: OR mask
      # 1's should be overwritten to 1: OR mask
      # X's should be set to 0 so they can be OR'd with options later
      or_mask = mask.gsub("X", "0").to_i(2)
      and_mask = mask.gsub("0", "1").gsub("X", "0").to_i(2)
      debug "address  #{address.to_s(2).rjust(36, "0")} (#{address})"
      debug "or mask  #{or_mask.to_s(2).rjust(36, "0")}"
      debug "and mask #{and_mask.to_s(2).rjust(36, "0")}"
      address = address & and_mask | or_mask
      debug "  ->     #{address.to_s(2).rjust(36, "0")} (#{address})"

      address_masks = [0, 1].repeated_permutation(bits.length).map do |values|
        sum = values.zip(bits).map { |v, bit| v * 2**bit }.sum
        # debug "  #{values}: #{sum}"
        sum
      end
      address_masks.each do |override|
        new_address = address | override
        debug "  writing #{value} to #{new_address}"
        memory[new_address] = value
      end
    else
      raise "wtf"
    end
  end

  memory.values.sum
end


ex1 = <<-EX
mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
mem[8] = 11
mem[7] = 101
mem[8] = 0
EX

ex2 = <<EX
mask = 000000000000000000000000000000X1001X
mem[42] = 100
mask = 00000000000000000000000000000000X0XX
mem[26] = 1
EX

part 1
with :part1
debug!
try ex1, expect: 165
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex2, expect: 208
no_debug!
try puzzle_input
