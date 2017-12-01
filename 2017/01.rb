def go(meth, input, expected = nil)
  value = meth.call(input)
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

# part one

def one(str)
  x = str.each_char.map(&:to_i)
  x.push x.first
  x.each_cons(2).inject(0) { |s,p| p[0] == p[1] ? s + p[0] : s }
end

puts "-- part one --"
go method(:one), "1122", 3
go method(:one), "1111", 4
go method(:one), "1234", 0
go method(:one), "91212129", 9
go method(:one), `pbpaste`

# part two

def two(str)
  list = str.each_char.map(&:to_i)
  len = list.length
  offset = len / 2 # always an even number of items
  sum = 0
  list.each.with_index do |value, index|
    if value == list[(index + offset) % len]
      sum += value
    end
  end
  sum
end

puts "-- part two --"
go method(:two), "1212", 6
go method(:two), "1221", 0
go method(:two), "123425", 4
go method(:two), "123123", 12
go method(:two), `pbpaste`
