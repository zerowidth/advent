require_relative "../toolkit"

class Cart
  DIRS = {
    ">" => [1, 0],
    "v" => [0, 1],
    "<" => [-1, 0],
    "^" => [0, -1]
  }
  TURNS = [-1, 0, 1]

  attr_reader :id, :x, :y, :dir

  def initialize(id, x, y, dir)
    @id = id
    @x = x
    @y = y
    @dir = dir
    @turn = 0 # which direction we're turning next
  end

  def to_s
    "<Cart #{id}: #{dir} at #{x}, #{y} (#{@turn})>"
  end

  def move(track)
    # debug "cart #{pos} moving #{dir}"
    # move a space:
    @x, @y = pos.zip(DIRS.fetch(@dir)).map(&:sum)
    # debug "  now #{pos}"
    # now that we've moved, see if we need to turn
    case track[y][x]
    when "|", "-"
      # nothing to do, keep moving
    when "/"
      case dir
      when ">", "<"
        turn(-1)
      when "v", "^"
        turn(1)
      end
    when "\\" # need to turn
      case dir
      when ">", "<"
        turn(1)
      when "v", "^"
        turn(-1)
      end
    when "+"
      turn(TURNS[@turn])
      @turn = (@turn + 1) % 3
    else
      raise "wtf? #{track[y][x].inspect}"
    end
  end

  def crashed!
    @crashed = true
  end

  def crashed?
    @crashed
  end

  def turn(which_direction)
    new_dir = (DIRS.keys.index(dir) + which_direction) % 4
    @dir = DIRS.keys[new_dir]
  end

  def pos
    [x, y]
  end
end

UNDERNEATH = {
  ">" => "-",
  "v" => "|",
  "^" => "|",
  "<" => "-"
}

def load_track(input)
  track = input.lines.map(&:chomp)

  carts = []
  track.each.with_index do |line, y|
    line.indices(/[<>^v]/).each do |x|
      carts << Cart.new(carts.length, x, y, line[x])
    end
  end

  track = track.map { |line| line.tr("\\^v<>", "||\\-\\-") }

  [track, carts]
end

def draw(track, carts)
  return unless debug?

  track.each.with_index do |line, y|
    to_draw = line.dup
    carts.select { |c| c.y == y && !c.crashed? }.each do |cart|
      if carts.any? { |c| c != cart && c.pos == cart.pos }
        to_draw[cart.x] = "X"
      else
        to_draw[cart.x] = cart.dir
      end
    end
    debug to_draw
  end
  debug
end

def part1(input)
  track, carts = load_track(input)
  draw track, carts

  loop do
    collision = false

    carts.sort_by { |c| [c.y, c.x] }.each do |cart|
      cart.move(track)
      if carts.any? { |c| c != cart && c.pos == cart.pos }
        collision = true
        break
      end
    end
    draw track, carts

    break if collision
  end

  carts.tally_by(&:pos).max_by { |_pos, count| count }.first.join(",")
end

def part2(input)
  track, carts = load_track(input)
  draw track, carts

  loop do
    carts.sort_by { |c| [c.y, c.x] }.each do |cart|
      next if cart.crashed?

      cart.move(track)
      collide = carts.select { |c| c != cart && c.pos == cart.pos }
      if collide.any?
        cart.crashed!
        collide.each(&:crashed!)
      end
    end
    draw track, carts

    carts = carts.reject(&:crashed?)

    break if carts.length == 1
  end

  carts.tally_by(&:pos).max_by { |_pos, count| count }.first.join(",")
end

ex1 = <<-EX
|
v
|
|
|
^
|
EX

ex2 = <<-EX
/->-\\
|   |  /----\\
| /-+--+-\\  |
| | |  | v  |
\\-+-/  \\-+--/
  \\------/
EX

ex3 = <<EX
/>-<\\
|   |
| /<+-\\
| | | v
\\>+</ |
  |   ^
  \\<->/
EX

part 1
with :part1
debug!
try ex1, expect: "0,3"
try ex2, expect: "7,3"
no_debug!
try puzzle_input # not 10,138

part 2
with :part2
debug!
try ex3, expect: "6,4"
no_debug!
try puzzle_input
