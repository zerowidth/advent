require_relative "../toolkit"
require_relative "./intcode"

def part1(input)
  cpus = []
  50.times do |n|
    cpu = Intcode.from_program(input)
    cpu << n
    cpus << cpu
  end

  count = 0
  found = nil
  loop do
    count += 1
    cpus.each.with_index do |cpu, n|
      # STDERR.puts "running cpu #{n}"
      cpu.run
      if cpu.waiting?
        # STDERR.puts "  -> waiting, no packets"
        cpu << -1
      end
      cpu.read_output.each_slice(3) do |addr, x, y|
        STDERR.puts "#{count} | cpu #{n} -> #{addr}: #{x}, #{y}"
        if addr == 255
          found = y
        elsif cpus[addr]
          cpus[addr] << x
          cpus[addr] << y
        end
      end
    end
    break found if found
  end
end

class Node
  attr_reader :num, :cpu, :inbox, :outbox

  def initialize(program, n)
    @num = n
    @cpu = Intcode.from_program(program)
    @inbox = [n]
    @outbox = []
  end

  def step
    if inbox.empty?
      cpu << -1
    else
      cpu << inbox.shift
    end
    cpu.run
    outbox.concat cpu.read_output
  end

  def <<(val)
    inbox << val
  end

  def idle?
    inbox.empty? && outbox.empty?
  end
end

def part2(input)
  nodes = 50.times.map do |n|
    Node.new input, n
  end

  count = 0
  nat = nil
  delivered_ys = Set.new
  loop do
    count += 1
    nodes.each { |node| node.step }

    if count > 1 && nodes.all?(&:idle?)
      STDERR.puts "#{count} | IDLE: sending #{nat}"
      nodes[0] << nat[0]
      nodes[0] << nat[1]
      if delivered_ys.include? nat[1]
        STDERR.puts "#{count} | already delivered!"
        break nat[1]
      end
      delivered_ys.add nat[1]
    end

    nodes.each.with_index do |node, n|
      node.outbox.each_slice(3) do |addr, x, y|
        STDERR.puts "#{count} | cpu #{n} -> #{addr}: #{x}, #{y}"
        if addr == 255
          nat = [x, y]
        elsif nodes[addr]
          nodes[addr] << x
          nodes[addr] << y
        end
      end
      node.outbox.clear
    end

    # break if count > 100
  end
end

part 1
with :part1
# try puzzle_input

part 2
with :part2
try puzzle_input
