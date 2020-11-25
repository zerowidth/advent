require_relative "../toolkit"
require_relative "./intcode"

class Spaceship
  attr_reader :cpu

  def initialize(program)
    @cpu = Intcode.from_program(program)
  end

  def perform(instructions)
    instructions = instructions.dup
    out = []
    loop do
      cpu.run

      break if cpu.halted?
      break if instructions.empty?

      out << cpu.read_output.map(&:chr).join

      instruction = instructions.shift
      input = instruction.chars.map(&:ord) + ["\n".ord]
      input.each { |char| cpu << char }
      out << instruction

      cpu.run
      out << cpu.read_output.map(&:chr).join
    end
    out
  end
end

def part1(input, instructions, items)
  ship = Spaceship.new(input)
  ship.perform(instructions).each do |out|
    # puts out
  end

  combinations = Enumerator.new do |y|
    0.upto(items.length) do |n|
      items.combination(n).each do |combination|
        y << combination
      end
    end
  end

  combinations.each do |to_keep|
    take = to_keep.map { |i| "take #{i}"}
    drop = to_keep.map { |i| "drop #{i}" }
    print "keeping: #{to_keep.inspect}: "
    result = ship.perform(take + ["south"]).last
    if result.include? "ejected"
      puts "ejected"
      ship.perform(drop)
    elsif result =~ /typing (\d+)/
      puts "success!"
      puts result
      return $1
    else
      puts
    end
  end
end

part 1

instructions = <<~IN
# start: hull breach: north, east
east
# stables: east, south, (west)
take loom
east # to science lab: north, (west)
take fixed point
north # to storage: north, west, (south)
take spool of cat6
north # to: gift wrapping: (south)
take weather machine
south # back to storage
west # to: sick bay: (east)
take shell
east # back to storage
south # back to science lab
west # back to stables
south # to: warp drive maintenance: (north), east, west
take ornament
east # to: crew quarters: south, (west)
south # to: holodeck: (north), east, south
east # to: engineering: (west)
# take infinite loop # don't do this
west # back to holodeck
south # to: arcade: (north)
# take giant electromagnet # don't
north # back to holodeck
north # back to crew quarters
west # back to warp drive
west # to: hallway: north, (east)
north # to: observatory: north, (south)
take candy cane
north # to: kitchen (south)
south # back to observatory
south # back to hallway
east # back to warp drive
north # back to stables
west # back to hull breach
north # to: passages: north, east, (south)
take wreath
east # to: corridor: east, (west)
east # to: hot chocolate fountain (west)
west # back to corridor
west # back to passages
north # to: navigation east, (south)
east # to: checkpoint: south, (west)
# inv
# drop everything now, so we can try combinations to get past the checkpoint
drop ornament
drop loom
drop spool of cat6
drop wreath
drop fixed point
drop shell
drop candy cane
drop weather machine # too heavy
IN
items = [
  "ornament",
  "loom",
  "spool of cat6",
  "wreath",
  "fixed point",
  "shell",
  "candy cane",
]
instructions = instructions
  .split("\n")
  .map { |s| s.sub(/#.*/, "") }
  .map(&:strip)
  .reject(&:empty?)
with :part1, instructions, items
try puzzle_input