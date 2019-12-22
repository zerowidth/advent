require_relative "../toolkit"
require_relative "./simple_grid"
require_relative "./intcode"

def tiles(program)
  memory = program.split(",").map(&:to_i)
  cpu = Intcode.new memory
  cpu.run
  cpu.output.each_slice(3).select { |x, y, tile| tile == 2 }.length
end

def game(program)
  Game.new(program).play
end

class Game
  TILES = [
    " ", # 0 is blank
    "#", # 1 is wall
    "X", # 2 is block
    "-", # 3 is paddle
    "0", # 4 is ball
  ]

  def initialize(program)
    memory = program.split(",").map(&:to_i)
    memory[0] = 2 # two quarters to play!
    @cpu = Intcode.new memory
    @display = SimpleGrid.new
    @score = 0
    @ball = @paddle = 0
  end

  def play
    loop do
      @cpu.run

      @cpu.output.each_slice(3) do |x, y, tile|
        if x == -1 && y == 0
          @score = tile
          next
        end
        @paddle = x if tile == 3
        @ball = x if tile == 4
        @display.set(x, y, TILES[tile])
      end

      break if @cpu.halted?

      @cpu << (@ball <=> @paddle)
      @cpu.output.clear

      # puts @display.to_s
      # puts "score #{@score}"
      # sleep 0.02
    end
    puts @display.to_s
    puts "score #{@score}"
  end
end


def draw(points)
  grid = SimpleGrid.new
  score = nil
  puts grid.inspect
  puts grid.to_s
  puts "score: #{score}"
end

part 1
with :tiles
try puzzle_input

part 2
with :game
try puzzle_input
