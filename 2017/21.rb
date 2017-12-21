require_relative "../toolkit"

def show(grid)
  size = Math.sqrt(grid.length).to_i
  grid.each_slice(size) do |slice|
    puts slice.join
  end
end

def rotate(grid)
  size = Math.sqrt(grid.length).to_i
  rotated = []
  if size == 2
    rotated << grid[2] << grid[0] << grid[3] << grid[1]
  elsif size == 3
    rotated << grid[6] << grid[3] << grid[0]
    rotated << grid[7] << grid[4] << grid[1]
    rotated << grid[8] << grid[5] << grid[2]
  else
    raise "wtf size #{size}"
  end
  rotated
end

def flip(grid)
  size = Math.sqrt(grid.length).to_i
  flipped = []
  if size == 2
    flipped << grid[1] << grid[0] << grid[3] << grid[2]
  elsif size == 3
    flipped << grid[2] << grid[1] << grid[0]
    flipped << grid[5] << grid[4] << grid[3]
    flipped << grid[8] << grid[7] << grid[6]
  else
    raise "wtf size #{size}"
  end
  flipped
end

def subdivide(grid)
  size = Math.sqrt(grid.length).to_i
  if grid.length % 2 == 0
    div = 2
  else
    div = 3
  end

  divided = []

  0.upto(size/div - 1) do |yoff|
    0.upto(size/div - 1) do |xoff|
      sub = []
      0.upto(div - 1) do |y|
        0.upto(div - 1) do |x|
          sub << grid[ x + xoff*div + y*size + yoff*size*div]
        end
      end
      divided << sub
    end
  end

  divided
end


def rejoin(grids)
  size = Math.sqrt(grids.size).to_i
  gs = Math.sqrt(grids.first.size).to_i
  joined = []
  grids.each_slice(size) do |row|
    rows = row.map { |r| r.each_slice(gs) }
    rows.first.zip(*rows[1..-1]).each do |rs|
      joined.push *rs.flatten
    end
  end
  joined
end


def enhance(grid, rules)
  size = Math.sqrt(grid.length).to_i
  if grid.length % 2 == 0
    enhanced = Array.new((size / 2 * 3) * (size / 2 * 3), ".")
    0.upto(size/2 - 1) do |xoff|
      0.upto(size/2 - 1) do |yoff|
        puts "xoff: #{xoff} yoff #{yoff}"
        sub = []
        0.upto(1) do |y|
          0.upto(1) do |x|
            sub << grid[x + xoff*2 + y*2 + y*size + yoff*2*size]
          end
        end
        puts "matching:"
        show sub
        replacement = rules[sub]
        puts "replacing with:"
        show replacement
        0.upto(2) do |x|
          0.upto(2) do |y|
            # puts "#{x} #{y} -> #{x + xoff * 3} + #{y * 3 + yoff * 3 * (size / 2 * 3 )}"
            enhanced[x + xoff * 3 + y * 3 + yoff * 3 * (size / 2 * 3)] = replacement[x + y*3]
          end
        end
      end
    end
  else
    enhanced = Array.new((size / 3 * 4) * (size / 3 * 4), ".")
    0.upto(size/3 - 1) do |xoff|
      0.upto(size/3 - 1) do |yoff|
        puts "xoff: #{xoff} yoff #{yoff}"
        sub = []
        0.upto(2) do |x|
          0.upto(2) do |y|
            sub << grid[x + y*3 + xoff*3 + yoff*3*size]
          end
        end
        puts "matching:"
        show sub
        replacement = rules[sub]
        puts "replacing with:"
        show replacement
        0.upto(3) do |x|
          0.upto(3) do |y|
            # puts "#{x} #{y} -> #{x + xoff * 4} + #{y * 4 + yoff * 4 * (size / 3 * 4 )}"
            enhanced[x + xoff * 4 + y * 4 + yoff * 4 * (size / 3 * 4)] = replacement[x + y*4]
          end
        end
      end
    end
  end
  enhanced
end

def solution(input, iterations)
  rules = {}
  input.lines.map do |line|
    match, replacement = *line.rstrip.split(" => ").map {|r| r.gsub("/","") }.map(&:chars)

    rules[match] = replacement
    rules[flip(match)] = replacement

    rotated = match
    3.times do
      rotated = rotate(rotated)
      rules[rotated] = replacement
      rules[flip(rotated)] = replacement
    end
  end

  grid = ".#...####".chars
  iterations.times do |n|
    size = Math.sqrt(grid.length).to_i
    puts "--- iteration #{n} with grid size #{size} ---"
    print "subdividing...\r"
    divided = subdivide(grid)
    print "replacing...  \r"
    replaced = divided.map do |search|
      if replacement = rules[search]
        replacement
      else
        puts "no replacement found for"
        show search
        raise
      end
    end
    print "rejoining...  \r"
    grid = rejoin(replaced)
    # puts "becomes"
    # show grid
  end

  # grid = ('a'..'p').to_a
  # show grid
  # subdivide(grid).each do |sub|
  #   puts "-"
  #   show sub
  # end
  # show rejoin(subdivide(grid))
  # puts "----"
  # grid = ('a'..'z').to_a + (0..9).to_a
  # show grid
  # subdivide(grid).each do |sub|
  #   puts "-"
  #   show sub
  # end
  # show rejoin(subdivide(grid))


  # iterations.times do
  #   puts "-----"
  #   show art
  #   art = enhance(art, rules)
  #   puts "results in"
  #   show art
  # end

  grid.group_by { |c| c }["#"].length
end

example = <<-EX
../.# => ##./#../...
.#./..#/### => #..#/..../..../#..#
EX

part 1
with(:solution, 2)
try example, 12
with(:solution, 5)
try puzzle_input

part 2
with(:solution, 18)
# try example, 0
try puzzle_input
