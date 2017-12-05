require "pp"

TERM_RED = "\e[31m"
TERM_GREEN = "\e[32m"
TERM_BLUE = "\e[34m"
TERM_PURPLE = "\e[35m"
TERM_RESET = "\e[0m"

def part(n)
  puts if n > 1
  puts "----- part #{n} -----"
  puts
end

def with(sym, *args, &block)
  print "-- with :#{sym} "
  print "(#{args.map(&:inspect).join(", ")}) " if args.length > 0
  print "(with block) " if block
  puts "--"
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
  if block_given?
    value = yield value
  end
  if expected.nil?
    puts "=> #{TERM_PURPLE}#{value}#{TERM_RESET}"
    puts
  else
    if value == expected
      puts "=> #{TERM_GREEN}#{value}#{TERM_RESET}"
    else
      puts "=> #{TERM_RED}#{value}#{TERM_RESET} (expect #{expected})"
    end
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
