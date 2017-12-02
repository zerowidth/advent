def with(sym, &block)
  @method = method(sym)
  @block = block
end

def try(input, expected = nil)
  puts "---"
  if expected
    print "#{input.strip}"
  else
    puts "puzzle input: "
    if input.lines.size > 1
      print input.lines.first(3).join
      print "..."
    elsif input.length > 80
      print input[0..80] + "..."
    else
      print input
    end
  end
  if input.include?("\n") || input.length > 80
    puts
  else
    print " "
  end
  value = @method.call(input, &@block)
  print "=> #{value}"
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

def puzzle_input
  File.read(caller.last.split(":").first.sub(".rb", ".txt"))
end

class String
  def digits
    each_char.map(&:to_i)
  end

  def numbers
    split(/\s+/).map(&:to_i)
  end

  def number_table
    lines.map(&:numbers).reject(&:empty?)
  end
end
