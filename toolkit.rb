require "pp"
require "set"

TERM_RED = "\e[31m"
TERM_GREEN = "\e[32m"
TERM_BLUE = "\e[34m"
TERM_PURPLE = "\e[35m"
TERM_RESET = "\e[0m"

def part(n)
  puts if n > 1
  puts "-" * 30 + " part #{n} " + "-" * 30
  puts
end

def with(sym, *args, **kwargs, &block)
  print "-" * 20 + " with :#{sym} "
  print "(#{args.map(&:inspect).join(", ")}) " if args.length > 0
  print "(with block) " if block
  puts "-" * 20
  @method = method(sym)
  @args = args
  @kwargs = kwargs
  @block = block
end

def try(input, *args, expect: :puzzle_input, **kwargs)
  # maintain parity with "older" API, before kwargs, to differentiate a normal
  # try(example, expected, arg, arg) from try(input, arg, arg, expected: ...)
  if expect == :puzzle_input && args.length > 0
    expect = args.shift
    if expect.nil? # explicit 'nil' to skip over arguments, again "old" api
      expect = :puzzle_input
    end
  end

  start = Time.now

  input_str = input.kind_of?(String) ? input.rstrip : input.inspect
  if expect.nil?
    print "\npuzzle input: "
  end
  if input_str.lines.size > 1
    print input_str.lines.first(3).join
    print "..."
  elsif input_str.length > 80
    print input_str[0..77] + "..."
  else
    print input_str
  end
  puts "\n---"

  # gather arguments including args from a `with` call:
  args = Array(@args) + Array(args)
  kwargs = @kwargs.merge(kwargs)
  # work around a ruby bug, ref:
  # https://bugs.ruby-lang.org/issues/11860
  # https://bugs.ruby-lang.org/issues/14183
  if kwargs.empty?
    value = @method.call(input, *args, &@block)
  else
    value = @method.call(input, *args, **kwargs, &@block)
  end

  value = yield value if block_given?

  if expect == :puzzle_input # explicitly not set!
    puts "=> #{TERM_PURPLE}#{value.inspect}#{TERM_RESET}"
    puts
  else
    if value == expect
      puts "=> #{TERM_GREEN}#{value.inspect}#{TERM_RESET}"
    else
      puts "=> #{TERM_RED}#{value.inspect}#{TERM_RESET} (expect #{expect.inspect})"
    end
  end

  elapsed = Time.now - start
  puts "* completed in #{"%0.5f" % elapsed.to_f} seconds"

  value
end

def puzzle_input
  file = caller.grep(%r(\d{4}/\d{2}\.rb)).first
  File.read(file.split(":").first.sub(".rb", ".txt"))
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

module Enumerable
  def map_with(method)
    map { |item| send(method, item) }
  end
end
