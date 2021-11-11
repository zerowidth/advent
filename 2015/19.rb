require_relative "../toolkit"
require_relative "../graph_search"

Signal.trap("INT") { exit }

ATOMS = /[eA-Z()][a-z]*/ # the () are for testing the Earley parser

ex1 = <<-EX
H => HO
H => OH
O => HH

HOH
EX

def part1(input)
  rules, input = input.split("\n\n", 2)
  rules = rules.split("\n").each_with_object({}) do |rule, hash|
    k, v = rule.strip.split(" => ", 2)
    hash[k] ||= []
    hash[k] << v
  end
  start = input.scan(ATOMS).to_a

  found = Set.new
  start.length.times do |i|
    if (matches = rules[start[i]])
      matches.each do |rule|
        replacement = start.dup
        replacement[i] = rule
        found << replacement.join
      end
    end
  end
  found.length
end

class Earley
  class Item
    attr_reader :lhs, :rhs, :dot, :from, :to

    # lhs: the nonterminal on the left-hand side of a rule
    # rhs: an array of terminals and nonterminals on the right hand side of a production rule
    # dot: the integer position in the rhs where this item is located
    # from: the integer starting position of this item
    # to: the integer position of the end of this item
    def initialize(lhs, rhs, dot, from, to)
      @lhs = lhs
      @rhs = rhs
      @dot = dot
      @from = from
      @to = to # implcitly encoded in state_set[i], but make it explicit for later
    end

    def length
      to - from
    end

    def prev
      dot.zero? ? nil : rhs[dot - 1]
    end

    def next
      rhs[dot]
    end

    def complete?
      rhs[dot].nil?
    end

    def to_s
      with_dot = rhs.dup
      with_dot.insert(dot, "•")
      "#{lhs} -> #{with_dot.join(" ")} (#{from}, #{to})"
    end

    def inspect
      "<#{self.class.name}: #{self}>"
    end

    include Comparable
    def <=>(other)
      o = other ? [other.lhs, other.rhs, other.dot, other.from, other.to] : nil
      [lhs, rhs, dot, from, to] <=> o
    end
  end

  class Terminal
    def initialize(symbol, pos)
      @symbol = symbol
      @pos = pos
    end

    def from
      @pos
    end

    def to_s
      @symbol.to_s
    end

    def inspect
      "<#{self.class.name}: #{self}>"
    end
  end

  attr_reader :rules

  def initialize(rules)
    @rules = rules
  end

  def recognize(input, starting_production)
    debug "recognizing #{input.map(&:to_s).join(" ")} starting from #{starting_production}"
    state_set = []
    (input.length + 1).times { state_set << [] }
    rules[starting_production].each do |rhs|
      state_set[0] << Item.new(starting_production, rhs, 0, 0, 0)
    end

    state_set.each.with_index do |set, pos|
      debug "--- S(#{pos}) ---"
      i = 0
      while (item = set[i])
        debug item
        if item.complete? # completion
          # debug "  completing #{item} at S(#{item.start})?"
          state_set[item.from].each do |start_item|
            if start_item.next == item.lhs
              completed = Item.new(start_item.lhs, start_item.rhs, start_item.dot + 1, start_item.from, pos)
              unless set.include?(completed)
                debug "  complete: #{item} : #{start_item} => #{completed}"
                set << completed
              end
            end
          end
          i += 1
          next
        end

        # This ignores a check for whether the next token is nonterminal, just
        # look up an expansion rule either way and see if we can predict any. In
        # our grammars, there's no distinction between terminals and
        # nonterminals.
        rules.fetch(item.next, []).each do |rhs|
          next_item = Item.new(item.next, rhs, 0, pos, pos)
          skip = set.include?(next_item)
          debug "  predict: #{item.next} => #{next_item}#{" (skip)" if skip}" unless skip
          set << next_item unless skip
        end

        # similarly: ignore if the next token is nonterminal, we only care if
        # it appears in the input stream
        if input[pos] == item.next
          next_item = Item.new(item.lhs, item.rhs, item.dot + 1, item.from, pos + 1)
          skip = state_set[pos + 1].include?(next_item)
          debug "  scan: #{item.next} => #{next_item}#{" (skip)" if skip}" unless skip
          state_set[pos + 1] << next_item unless skip
        end

        i += 1
      end
    end

    state_set.map { |set| set.select(&:complete?) }
  end

  def parse(input, starting_production)
    state_set = recognize(input, starting_production)

    recognized = state_set.last.select { |item| item.complete? && item.from.zero? && item.lhs == starting_production }
    return nil if recognized.empty?

    puts "recognized! #{recognized}"
    recognized = recognized.first # FIXME: make this a loop again

    by_start = state_set.flatten.group_by(&:from)
    debug "\nbuilding parse tree from:"
    by_start.each do |i, set|
      debug "=== #{i} ==="
      debug set.map(&:to_s).join("\n")
      debug
    end

    build_tree(recognized, input, by_start)
  end

  def build_tree(item, input, states, tree = [item])
    parts = decompose(item, input, states, 0, item.from)
    tree + parts.map { |part| build_tree(part, input, states, [part]) }
  end

  # Using the completed earley items, determine which items or implicit
  # terminals match the given completed item and input.
  #
  # item: the item we're decomposing
  # input: the input symbols
  # states: Hash[item start] => Array[Earley::Item] completed items
  # depth: which symbol in the item we're looking for
  # pos: which position in the state chart we're at
  # items: the items found so far
  def decompose(root, input, states, depth = 0, pos = 0, items = [])
    indent = " " * (depth * 2)
    debug "#{indent}decompose #{root} at depth #{depth} pos #{pos} #{items.inspect}"

    if root.kind_of?(Earley::Terminal) || pos == root.to
      debug "#{indent}  matched: #{items.inspect}"
      return items
    end

    if depth >= root.rhs.length || pos > root.to
      debug "#{indent}  no match"
      return nil
    end

    symbol = root.rhs[depth]

    # check for terminals
    if input[pos] == symbol
      debug "#{indent}  input matches at #{pos}"
      terminal = Earley::Terminal.new(symbol, pos)
      if (path = decompose(root, input, states, depth + 1, pos + 1, items))
        debug "#{indent}  found with terminal #{symbol}: #{path.inspect}"
        return path
      end
    end

    # look at rules that might match
    to_search = states.fetch(pos, []).select { |item| item.lhs == symbol }
    to_search.each do |match|
      if (path = decompose(root, input, states, depth + 1, pos + match.length, items + [match]))
        debug "#{indent}  #{match} -> match"
        return path
      else
        debug "#{indent}  #{match} -> nil"
      end
    end

    nil
  end
end

def part2(input)
  rules, input = input.split("\n\n", 2)
  rules = rules.split("\n").each_with_object(Hash.new) do |rule, hash|
    k, v = rule.strip.split(" => ", 2)
    hash[k] ||= []
    hash[k] << v.scan(ATOMS).to_a
  end
  medicine = input.strip.scan(ATOMS).to_a

  parser = Earley.new(rules)
  tree = parser.parse(medicine, "e")
  puts tree.pretty_inspect
  tree.flatten.length
end

part 1
with :part1
try ex1, expect: 4
try puzzle_input

# simple test
ex2 = <<-EX
e => H
e => O
H => HO
H => OH
O => HH

HOH
EX

ex3 = <<-EX
e => H
e => O
H => HO
H => OH
O => HH

HOHOHO
EX

# This is directly derived from the comments on reddit about the form of the
# language the puzzle input takes (and as validated by the puzzle author!)
# The puzzle input, even when "downconverted" to this simplified form, still
# took 300k iterations of a search using a replacement tree.
#
# The input string here is a "long-enough" subset, slightly modified, of my
# original puzzle input: complex enough to serve as a good example for a
# parser.
#
# XX(X(X,XX,X)X)XX
ex4 = <<-EX
e => XX
X => XX
X => X(X)

XX(X(X,XX,X)X)XX
EX

ex5 = <<-EX
e => XX
X => XX
X => X(X)
X => X(X,X)
X => X(X,X,X)

XX(X(X,XX,X)X)XX
EX
ex6 = <<-EX
e => XX
X => XX
X => X(X)
X => X(X,X)
X => X(X,X,X)

XXXXX(X(X(X,XXXX,X)X)X)XXXXXXXX(XX)XXX(XXXX)X(X,X)XXX(XXXX)
EX

# this is the simplified puzzle input, to prove this thing works at all before
# trying to parse the real puzzle input
ex7 = <<-EX
e => XX
X => XX
X => X(X)
X => X(X,X)
X => X(X,X,X)

X(XX(XX(X)XXXXXXX)XXXXXX(XXXXXX)XX(XX)XXXXX(X)(X(X)XXXX)XXX(XXXXX(X)X,X(X,XX)XXXXXXXXXX)XX(XX)XXXXX(X,XXX(X))XXX(XXX(X)X,XXXXXXXXXX)XXX(XXXX)XXXXXXXXXXXXXXXXXX(X,X)XXXX(X)XXXX(X,X)XXXXXXXXX(XX)(X)XXXXX(X)XXXXX(XXX(X,X)X)XXXXX)XXXX(X(XX)X)XXXXXXXX(XX)XXX(XXXX)X(X,X)XXX(XXXX)
EX

part 2
with :part2
debug!
try ex2, expect: 3
try ex3, expect: 6
try ex4, expect: 9
# try ex5, expect: 38
# try ex6, expect: 195
# try ex7, expect: 195
no_debug!
try puzzle_input
