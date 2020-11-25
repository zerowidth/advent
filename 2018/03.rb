require_relative "../toolkit"

def overlapping(input)
  claims = input.split("\n").map do |line|
    line.scan(/(\d+)/).flatten.drop(1).map(&:to_i)
  end
  fabric = Hash.new(0)
  claims.each do |sx,sy,w,h|
    (sx...sx+w).each do |x|
      (sy...sy+h).each do |y|
        fabric[[x,y]] += 1
      end
    end
  end
  fabric.values.count { |v| v > 1 }
end

ex1 = <<-EX
#1 @ 1,3: 4x4
#2 @ 3,1: 4x4
#3 @ 5,5: 2x2
EX

def unique_claim(input)
  claims = input.split("\n").map do |line|
    line.scan(/(\d+)/).flatten.map(&:to_i)
  end

  claims.reject do |a|
    STDERR.puts "checking #{a}"
    claims.any? do |b|
      next if a == b
      ox = overlaps?([a[1], a[1]+a[3]-1], [b[1], b[1]+b[3]-1])
      oy = overlaps?([a[2], a[2]+a[4]-1], [b[2], b[2]+b[4]-1])
      STDERR.puts "  against #{b}: #{ox} #{oy}"
      ox || oy
    end
  end
end

def overlaps?(a, b)
  # false only if:
  # a is to the left of b
  # a is to the right of b
  a, b = b, a if a[0] > b[0]
  x = (a[0] < b[0] && a[1] >= b[0]) || a[0] < b[1]
  STDERR.puts "    #{a} vs #{b}: #{x}"
  x
end

part 1
with :overlapping
try ex1, 4
try puzzle_input

part 2
with :unique_claim
try ex1, 3
# try ex2, nil
# try puzzle_input
