require_relative "../toolkit"

def turing(input)
  machine = Machine.parse(input)
  machine.run_until_diagnostic
  machine.diagnostic
end

class Tape
  attr_reader :pos

  def initialize
    @pos = 0
    @ones = {}
  end

  def read
    if @ones.key?(@pos)
      1
    else
      0
    end
  end

  def write(value)
    if value == 0
      @ones.delete(@pos)
    else
      @ones[@pos] = 1
    end
  end

  def move(dir)
    @pos += dir
  end

  def checksum
    @ones.keys.length
  end
  def ones
    @ones.keys.sort
  end
end

class Machine

  def self.parse(input)
    sections = input.split("\n\n")
    first = sections.shift
    /Begin in state (?<start>.)\./ =~ first or raise
    /after (?<diag>\d+) steps/ =~ first or raise
    machine = Machine.new(start, diag.to_i)

    sections.each do |section|
      head, zero, one = section.split("current value")
      /In state (?<state>.):/ =~ head or raise
      rules = [zero, one].map do |sec|
        /Write the value (?<write>\d)/ =~ sec or raise
        /to the (?<move>left|right)/ =~ sec or raise
        /with state (?<next_state>.)\./ =~ sec or raise
        move = move == "left" ? -1 : 1
        [write.to_i, move, next_state]
      end

      machine.rule state, *rules
    end

    machine
  end

  def initialize(start, diag_after)
    @state = start
    @after = diag_after
    @rules = {} # current state, with 0 or 1 rule, [write, move, nextstate]
    @tape = Tape.new
  end

  def rule(state, zero, one)
    @rules[state] = [zero, one]
  end

  def run_until_diagnostic
    @after.times do |n|
      # print "step #{n+1}: #{@state} @#{@tape.pos}:#{@tape.read} : "
      rules = @rules.fetch(@state)
      val = @tape.read
      write, move, nextstate = *rules[val]
      # print "write #{write} move #{move} next #{nextstate} "
      @tape.write write
      @tape.move move
      @state = nextstate
      # puts @tape.ones.inspect
      print "state #{n}\r" if n % 1000 == 0
    end
    puts
  end

  def diagnostic
    @tape.checksum
  end
end

example = <<-EX
Begin in state A.
Perform a diagnostic checksum after 6 steps.

In state A:
  If the current value is 0:
    - Write the value 1.
    - Move one slot to the right.
    - Continue with state B.
  If the current value is 1:
    - Write the value 0.
    - Move one slot to the left.
    - Continue with state B.

In state B:
  If the current value is 0:
    - Write the value 1.
    - Move one slot to the left.
    - Continue with state A.
  If the current value is 1:
    - Write the value 1.
    - Move one slot to the right.
    - Continue with state A.
EX

part 1
with(:turing)
try example, 3
try puzzle_input

# part 2
# with(:solution)
# try example, 0
# try puzzle_input
