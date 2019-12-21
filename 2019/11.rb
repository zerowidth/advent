require_relative "../toolkit"
require_relative "./intcode"

class Painter
  attr_reader :painted

  def initialize(program)
    memory = program.split(",").map(&:to_i)
    @cpu = Intcode.new(memory)
    @bot = [0,0]
    @dir = [0,1]
    @dirs = [[0,1],[1,0],[0,-1],[-1,0]]
    @painted = Hash.new(0) # 0 is black
  end

  def run(start_color)
    @painted[@bot] = start_color
    while !@cpu.halted?
      @cpu << @painted[@bot]
      @cpu.run
      paint = @cpu.output.shift
      turn = @cpu.output.shift
      # STDERR.puts "#{@bot} facing #{@dir} on #{@painted[@bot]}: paint #{paint}, turn #{turn}"
      @painted[@bot] = paint
      if turn == 0
        @dirs = @dirs.rotate(1) # turn right
      else
        @dirs = @dirs.rotate(-1) # turn left
      end
      @dir = @dirs.first
      @bot = @bot.zip(@dir).map(&:sum) # move one space
    end
  end

  def to_s
    s = ""
    keys = @painted.keys
    xmin = keys.map(&:first).min
    xmax = keys.map(&:first).max
    ymin = keys.map(&:last).min
    ymax = keys.map(&:last).max
    # the identifiers are painted upside down
    ymax.downto(ymin) do |y|
      xmax.downto(xmin) do |x|
        s << (@painted[[x,y]] == 0 ? "  " : "##")
      end
      s << "\n"
    end
    s
  end
end

def paint(input, start_color)
  bot = Painter.new(input)
  bot.run start_color
  bot
end

part 1
with :paint, 0
try puzzle_input do |bot|
  puts bot.to_s
  bot.painted.length
end

part 2
with :paint, 1
try puzzle_input do |bot|
  puts bot.to_s
  nil
end
