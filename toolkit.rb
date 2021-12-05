require "bundler"
Bundler.setup
require "tty-progressbar"
require "colorize"
require "diffy"
require "parser/current"

require "pp"
require "set"

Diffy::Diff.default_format = :color

$debug = false

def debug?
  $debug
end

def debug!
  $debug = true
end

def no_debug!
  $debug = false
end

def debug(*args)
  puts(*args) if $debug
end

def dpp(*args)
  pp(*args) if $debug
end

def part(n)
  puts if n > 1
  puts((("*" * 30) + " part #{n} " + ("*" * 30)).colorize(:blue))
end

# Use the given method for subsequent try calls.
#
# The method is invoked with args, keyword args, and a block, if given.
def with(sym, *args, **kwargs, &block)
  puts
  s = "with :#{sym} "
  s << "#{args.map(&:inspect).join(", ")} " if args.length.positive?
  s << "#{kwargs.inspect[1..-2]} " if kwargs.length.positive?
  s << "(with block) " if block
  puts s.colorize(:cyan)
  puts "-" * s.length
  @method = method(sym)
  @args = args
  @kwargs = kwargs
  @block = block
end

# try an input with the configured `with` method
#
# If the input is not a PuzzleInput, an expected value is required.
#
# Implicit expected value:
#
#   try input, expected
#   try arg1, arg2, expected
#
# Explicit expected value:
#
#   try input, expect: expected
#   try arg1, arg2, expect: expected
#
# all versions can take a block to modify the value after it's calculated.
#
# Given
#
#   def a(*args) end
#   with :a, 1, kwarg: value
#
# Then:
#
#   try 2, 3
#
# will invoke a(2, 1, 3, kwarg: value)
#
# The first `try` arg comes first since it's implicitly the puzzle or example input.
#
def try(*args, expect: nil)
  unless args.first.is_a?(PuzzleInput)
    expect ||= args.pop
    raise ArgumentError.new, "must provide at least one input and an expected value" if args.empty?

    # wrap input strings
    args[0] = Input.new(args.first) if args.first.is_a?(String)
  end

  if args.first.is_a?(PuzzleInput)
    arg_name = "puzzle input"
  elsif args.length == 1
    # overengineered: common case is an example (huge string), so get the _name_
    # of the example input using a parser.
    file, line = *caller.first.split(":")

    # figure out what character the line starts at so we can match it with the parse tree
    buf = File.read(file)
    # first newline + 1 means line 2
    start = buf.indices("\n").to_a[line.to_i - 2] + 1
    # parse the source, find the `try` invocation, get the argument name
    source = Parser::CurrentRuby.parse(buf)
    tries = source.children.select do |child|
      (child.type == :send && child.children[1] == :try) ||
        # block invocation is `try(arg) { block }`
        (child.type == :block && child.children[0].type == :send && child.children[0].children[1] == :try)
    end

    # unwrap blocks (block (send nil :try ...)) -> (send nil :try ...)
    tries = tries.map { |child| child.type == :block ? child.children[0] : child }
    arg_name = if (invocation = tries.detect { |c| c.loc.selector.begin_pos == start })
        input_arg = invocation.children[2]
        case input_arg.type
        when :send
          input_arg.children[2].to_s # local func call
        when :lvar
          input_arg.children.first.to_s # name of the lvar
        when :const
          input_arg.children[1].to_s # name of the const
        when :str, :int
          args.first.to_s
        else
          puts "unknown argument type: #{input_arg}".colorize(:red)
          args.first.inspect
        end
      else
        puts "no arg found on line #{line} (pos #{start})".colorize(:red)
        args.first.inspect
      end
  else
    arg_name = args.inspect
  end

  puts
  puts "try #{arg_name.colorize(:yellow)}"
  puts "-" * (4 + arg_name.length)

  if args.first.is_a?(PuzzleInput) && ENV["SKIP_INPUT"]
    puts "(skipping)"
    return
  end

  start = Time.now

  # invoke the method including arguments from `with`:
  call_args = args.take(1) + @args + args.drop(1)
  value = @method.call(*call_args, **@kwargs, &@block)
  # allow transformation by block
  value = yield value if block_given?

  elapsed = Time.now - start
  puts "-> completed in #{"%0.5f" % elapsed.to_f} seconds"

  if args.first.is_a?(PuzzleInput)
    print "=> #{value.inspect.colorize(:magenta)}"

    # if this looks like valid output, put it on the clipboard
    stringish = value.is_a?(String) && !value.include?("\n") && value.length < 80
    number = value.is_a?(Integer) && !value.zero?
    # env var to prevent clipboard spam when running multiple days in a row
    if ENV["COPY_RESULT"] && (stringish || number)
      IO.popen("pbcopy", "w") { |io| io.write value.to_s }
      puts " (copied)"
    else
      puts
    end
    puts
  elsif value == expect
    puts "=> #{value.inspect.colorize(:green)}"
  else
    puts "=> #{"mismatch:".colorize(:red)}\n"
    puts diff(expect, value)
    exit 1
  end
  value
end

def diff(expected, value)
  ex = expected.nil? ? "nil" : expected.to_s
  val = value.nil? ? "nil" : value.to_s
  puts Diffy::Diff.new("#{ex}\n", "#{val}\n")
end

class Input < String
  def initialize(str)
    super str.chomp
  end

  def lines
    super(chomp: true)
  end

  def each_line(*)
    super(chomp: true)
  end

  def sections
    split("\n\n").map { |s| self.class.new(s) }
  end

  def lines_of(m)
    lines.map(&m)
  end
end

# for input checking in the very generic `try` helper
class PuzzleInput < Input
end

def puzzle_input
  file = caller.grep(%r(\d{4}/\d{2}\.rb)).first
  PuzzleInput.new(File.read(file.split(":").first.sub(".rb", ".txt")))
end

class Integer
  # Thanks to https://gist.github.com/jingoro/2388745
  # Returns an array of the form `[gcd(x, y), a, b]`, where
  # `ax + by = gcd(x, y)`.
  #
  # @param [Integer] y
  # @return [Array<Integer>]
  def gcdext(y)
    if negative?
      g, a, b = (-self).gcdext(y)
      return [g, -a, b]
    end
    if y.negative?
      g, a, b = gcdext(-y)
      return [g, a, -b]
    end
    r0, r1 = self, y
    a0 = b1 = 1
    a1 = b0 = 0
    until r1.zero?
      q = r0 / r1
      r0, r1 = r1, r0 - (q * r1)
      a0, a1 = a1, a0 - (q * a1)
      b0, b1 = b1, b0 - (q * b1)
    end
    [r0, a0, b0]
  end

  def inverse_mod(mod)
    g, a, = gcdext(mod)
    raise ZeroDivisionError, "#{self} has no inverse modulo #{mod}" unless g == 1

    a % mod
  end

  def to(other)
    if other > self
      upto(other)
    elsif other < self
      downto(other)
    else
      [self].repeated
    end
  end

  # more efficient than shoving .times.each through an enumerator
  def times_with_progress(title: nil, &block)
    return times(&block) if debug?

    bar = progress_bar(title: title, total: self)
    increment = [self / 10_000, 1].max # only increment this many times
    times do |n|
      yield n
      bar.advance(increment) if n % increment == 0
    end
  ensure
    bar&.finish
  end
end

class String
  def digits
    each_char.map(&:to_i)
  end

  def numbers
    scan(/\d+/).map(&:to_i)
  end

  def number
    numbers.first
  end

  def number_table
    lines.map(&:numbers).reject(&:empty?)
  end

  def indices(search)
    position = 0
    Enumerator.new do |yielder|
      while (pos = index(search, position))
        yielder << pos
        position = pos + 1
      end
    end
  end
end

class Hash
  def self.of
    new { |h, k| h[k] = yield }
  end

  def self.of_array
    of { [] }
  end

  def self.of_set
    of { Set.new }
  end
end

module Enumerable
  def map_with(method)
    map { |item| send(method, item) }
  end

  def tally_by(&fn)
    group_by(&fn).transform_values(&:size)
  end

  def all_combinations(min_length: 1, max_length: length)
    Enumerator.new do |y|
      min_length.upto(max_length).each do |len|
        combination(len).each { |c| y << c }
      end
    end
  end

  def all_sequences(min_length: 1)
    Enumerator.new do |y|
      min_length.upto(length) do |len|
        each_cons(len) { |seq| y << seq }
      end
    end
  end

  def repeated
    Enumerator.new do |y|
      loop { each { |v| y << v } }
    end
  end

  def safe_zip(*others)
    ([self] + others).any? { |enum| enum.size && enum.size < Float::INFINITY } or
      raise ArgumentError, "all enumerators in safe_size are infinite"
    Enumerator.new do |y|
      lazy.zip(*others).each do |vs|
        break if vs.any?(&:nil?)

        y << vs
      end
    end
  end

  def with_progress(title: nil, total: nil, length: false, &block)
    return each(&block) if debug?

    total = self.length if length
    progress_bar(title: title, total: total).iterate(self)
  end
end

# construct a default progress bar to use everywhere
def progress_bar(title: nil, total: nil)
  title = title ? "#{title}: " : ""

  if total
    name = "#{title}:elapsed :eta :current/:total :rate/sec [:bar]"
  else
    name = "#{title}:elapsed :current :rate/sec"
  end

  TTY::ProgressBar.new(name, frequency: 10, total: total, bar_format: :dot)
end
