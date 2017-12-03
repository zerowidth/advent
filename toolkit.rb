require "pp"

def part(n)
  puts if n > 1
  puts "----- part #{n} -----"
  puts
end

def with(sym, *args, &block)
  puts "-- with :#{sym} --"
  @method = method(sym)
  @args = args
  @block = block
end

def try(input, expected = nil, *args)
  if !expected.nil?
    print "#{input.strip}"
  else
    puts "\npuzzle input: "
    if input.lines.size > 1
      print input.lines.first(3).join
      print "..."
    elsif input.length > 80
      print input[0..77] + "..."
    else
      print input
    end
  end
  if input.include?("\n") || input.length > 80
    puts
  else
    print " "
  end
  args = Array(@args) + Array(args)
  value = @method.call(input, *args, &@block)
  print "=> #{value}"
  if !expected.nil?
    if value == expected
      puts " (OK)"
    else
      puts " (FAIL: expect #{expected})"
    end
  else
    puts
  end
  value
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
