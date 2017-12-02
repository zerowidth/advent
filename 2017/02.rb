def go(sym, input, expected = nil)
  print "#{input} => "
  value = method(sym).call(input)
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

def checksum(input)
  rows = input.lines.map(&:strip).reject(&:empty?).map { |l| l.split(/\s+/).map(&:to_i) }
  rows.map { |row| row.max - row.min }.sum
end

s = <<-S
5 1 9 5
7 5 3
2 4 6 8
S

go :checksum, s, 18
go :checksum, `pbpaste`
