def go(input, value, expected = nil)
  print "#{input} => #{value}"
  if expected
    if value == expected
      puts " (OK)"
    else
      puts " (FAIL: expect #{expected})"
    end
  else
    puts
  end
end

def checksum(input, &block)
  rows = input.lines.map(&:strip).reject(&:empty?).map { |l| l.split(/\s+/).map(&:to_i) }
  rows.map(&block).sum
end

s = <<-S
5 1 9 5
7 5 3
2 4 6 8
S

# go(s, checksum(s) { |row| row.max - row.min }, 18)
# go(`pbpaste`, checksum(`pbpaste`) { |row| row.max - row.min })

t = <<-T
5 9 2 8
9 4 7 3
3 8 6 5
T

x = checksum(`pbpaste`) do |row|
  # evenly divides means mod is 0
  sum = 0
  row.each do |i|
    row.each do |j|
      if i > j && i % j == 0
        sum += (i / j)
      end
    end
  end
  sum
end
puts x
