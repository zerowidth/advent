require_relative "../toolkit"

def lights(instructions, on, off, toggle)
  lights = Array.new(1_000_000, 0)
  instructions.lines.each do |line|
    if line =~ /(\d+),(\d+) through (\d+),(\d+)/
      x1, y1, x2, y2 = $1, $2, $3, $4
      op = case line
      when /turn on/
        on
      when /turn off/
        off
      when /toggle/
        toggle
      else
        raise "uhhhh: #{line}"
      end

      switch(lights, x1.to_i, y1.to_i, x2.to_i, y2.to_i, &op) if op
    end
  end
  lights.sum
end

def switch(lights, x1, y1, x2, y2, &block)
  y1.upto(y2) do |y|
    x1.upto(x2) do |x|
      i = y * 1000 + x
      lights[i] = yield lights[i]
    end
  end
end

part 1

s = <<STR
turn on 0,0 through 999,999
toggle 0,0 through 999,0
turn off 499,499 through 500,500
STR

ON = Proc.new { 1 }
OFF = Proc.new { 0 }
TOGGLE = Proc.new { |light| light > 0 ? 0 : 1 }

with :lights, ON, OFF, TOGGLE
try s, 1_000_000 - 1000 - 4
try "turn on 0,0 through 0,2", 3
try "turn on 0,0 through 0,2\ntoggle 0,0 through 0,1", 1
try "toggle 0,0 through 0,1", 2
try puzzle_input

part 2

TURN_UP = Proc.new { |v| v + 1 }
TURN_DOWN = Proc.new { |v| v > 0 ? v - 1 : 0 }
TWICE_UP = Proc.new { |v| v + 2 }

with :lights, TURN_UP, TURN_DOWN, TWICE_UP
try "turn on 0,0 through 0,0", 1
try "turn off 0,0 through 0,0", 0
try "toggle 0,0 through 999,999", 2_000_000
try puzzle_input
