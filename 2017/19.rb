require_relative "../toolkit"

def letters(input)
  map = input.lines.map(&:rstrip)

  y = 0
  x = map[0].index("|")
  px = x
  py = -1

  seen = ""
  steps = 1

  loop do
    val = map[y][x]
    if val =~ /[A-Za-z]/
      seen << val
    end
    # puts [[x, y], val].inspect
    nx, ny = *next_move(map, x, y, px, py)
    break unless nx && ny
    steps += 1
    px = x
    py = y
    x = nx
    y = ny
  end

  yield [seen, steps]
end

def next_move(map, x, y, px, py)
  dirx = x - px
  diry = y - py
  # puts "  dirx #{dirx} diry #{diry}"

  if (row = map[y + diry]) && val = map[y + diry][x + dirx]
    if val != " "
      return [x + dirx, y + diry]
    end
  end

  # look left and right of the current direction
  if dirx == 0
    candidates = [[x - 1, y], [x + 1, y]]
  else
    candidates = [[x, y - 1], [x, y + 1]]
  end
  # puts "  candidates #{candidates.inspect}"
  if c = candidates.detect { |cx, cy| map[cy] && map[cy][cx] && map[cy][cx] != " " }
    return c
  end
  return nil
end

example = <<EX
     |          
     |  +--+    
     A  |  C    
 F---|----E|--+ 
     |  |  |  D 
     +B-+  +--+ 
EX

part 1
with(:letters) { |seen, steps| seen }
try example, "ABCDEF"
try puzzle_input

part 2
with(:letters) { |seen, steps| steps }
try example, 38
try puzzle_input
