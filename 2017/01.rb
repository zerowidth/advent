def go(meth, input, expected = nil)
  print "#{input} => "
  value = meth.call(input)
  print "#{value}"
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

def sum_with_matching_offset(list, offset)
  list.zip(list.rotate(offset)).select { |a, b| a == b }.map(&:first).sum
end

# part one

def one(str)
  x = str.each_char.map(&:to_i)
  sum_with_matching_offset x, 1
end

puts "-- part one --"
go method(:one), "1122", 3
go method(:one), "1111", 4
go method(:one), "1234", 0
go method(:one), "91212129", 9
go method(:one), `pbpaste`

# part two

def two(str)
  x = str.each_char.map(&:to_i)
  sum_with_matching_offset x, x.length/2
end

puts "-- part two --"
go method(:two), "1212", 6
go method(:two), "1221", 0
go method(:two), "123425", 4
go method(:two), "123123", 12
go method(:two), `pbpaste`
