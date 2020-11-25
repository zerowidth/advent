require "bundler"
Bundler.setup

require "pp"
require "set"

require "diffy"
Diffy::Diff.default_format = :color

TERM_RED = "\e[31m"
TERM_GREEN = "\e[32m"
TERM_YELLOW = "\e[33m"
TERM_BLUE = "\e[34m"
TERM_PURPLE = "\e[35m"
TERM_CYAN = "\e[36m"
TERM_RESET = "\e[0m"

def part(n)
  puts if n > 1
  puts TERM_BLUE + "*" * 30 + " part #{n} " + "*" * 30 + TERM_RESET
end

def with(sym, *args, **kwargs, &block)
  puts
  s = "with :#{sym} "
  s << "#{args.map(&:inspect).join(", ")} " if args.length > 0
  s << "#{kwargs.inspect[1..-2]} " if kwargs.length > 0
  s << "(with block) " if block
  puts "#{TERM_CYAN}#{s}#{TERM_RESET}"
  puts "-" * s.length
  @method = method(sym)
  @args = args
  @kwargs = kwargs
  @block = block
end

def try(input, *args, expect: :puzzle_input, **kwargs)
  file, line = *caller.first.split(":")
  # get the first argument:
  arg = File.readlines(file)[line.to_i - 1].scan(/try (\w+),?/).first.first
  puts
  puts "try #{TERM_YELLOW}#{arg}#{TERM_RESET}"
  puts "-" * (4 + arg.length)

  # maintain parity with "older" API, before kwargs, to differentiate a normal
  # try(example, expected, arg, arg) from try(input, arg, arg, expected: ...)
  if expect == :puzzle_input && args.length > 0
    expect = args.shift
    if expect.nil? # explicit 'nil' to skip over arguments, again "old" api
      expect = :puzzle_input
    end
  end

  start = Time.now

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

  elapsed = Time.now - start
  puts "-> completed in #{"%0.5f" % elapsed.to_f} seconds"

  if expect == :puzzle_input # explicitly not set, this is newly calculated
    puts "=> #{TERM_PURPLE}#{value.inspect}#{TERM_RESET}"
    puts
  elsif value == expect
    puts "=> #{TERM_GREEN}#{value.inspect}#{TERM_RESET}"
  else
    puts "=> #{TERM_RED}mismatch:#{TERM_RESET}\n"
    puts Diffy::Diff.new(expect.to_s + "\n", value.to_s + "\n")
  end
  value
end

def puzzle_input
  file = caller.grep(%r(\d{4}/\d{2}\.rb)).first
  File.read(file.split(":").first.sub(".rb", ".txt"))
end

class Integer
  # Thanks to https://gist.github.com/jingoro/2388745
  # Returns an array of the form `[gcd(x, y), a, b]`, where
  # `ax + by = gcd(x, y)`.
  #
  # @param [Integer] y
  # @return [Array<Integer>]
  def gcdext(y)
    if self < 0
      g, a, b = (-self).gcdext(y)
      return [g, -a, b]
    end
    if y < 0
      g, a, b = self.gcdext(-y)
      return [g, a, -b]
    end
    r0, r1 = self, y
    a0 = b1 = 1
    a1 = b0 = 0
    until r1.zero?
      q = r0 / r1
      r0, r1 = r1, r0 - q*r1
      a0, a1 = a1, a0 - q*a1
      b0, b1 = b1, b0 - q*b1
    end
    [r0, a0, b0]
  end

  def inverse_mod(mod)
    g, a, _ = gcdext(mod)
    unless g == 1
      raise ZeroDivisionError.new("#{self} has no inverse modulo #{mod}")
    end
    a % mod
  end
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
