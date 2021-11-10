require_relative "../toolkit"
require_relative "../graph_search"

Signal.trap("INT") { exit }

ATOMS = /[eA-Z()][a-z]*/

ex1 = <<-EX
H => HO
H => OH
O => HH

HOH
EX

def part1(input)
  rules, input = input.split("\n\n", 2)
  rules = rules.split("\n").each_with_object(Hash.new) do |rule, hash|
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
        found << replacement.join("")
      end
    end
  end
  found.length
end

class Earley

  class Item
    attr_reader :lhs, :rhs, :dot, :start, :pos

    # lhs: the nonterminal on the left-hand side of a rule
    # rhs: an array of terminals and nonterminals on the right hand side of a production rule
    # dot: the integer position in the rhs where this item is located
    # start: the integer starting position of this item
    def initialize(lhs, rhs, dot, start, pos)
      @lhs = lhs
      @rhs = rhs
      @dot = dot
      @start = start
      @pos = pos # implcitly encoded in state_set[i], but make it explicit for later
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
      "#{lhs} -> #{with_dot.join(" ")} (#{start}) @ #{pos}"
    end

    def inspect
      "<#{self.class.name}: #{self}>"
    end

    include Comparable
    def <=>(other)
      o = other ? [other.lhs, other.rhs, other.dot, other.start, other.pos] : nil
      [lhs, rhs, dot, start, pos] <=> o
    end
  end

  attr_reader :rules

  def initialize(rules, debug: false)
    @rules = rules
    @debug = debug
  end

  def debug(msg)
    puts msg if @debug
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
          state_set[item.start].each do |start_item|
            if start_item.next == item.lhs
              completed = Item.new(start_item.lhs, start_item.rhs, start_item.dot + 1, start_item.start, pos)
              unless set.include?(completed)
                debug "  complete: #{item} : #{start_item} => #{completed}"
                set << completed
              end
            end
          end
          i += 1
          next
        end

        # this ignores a check for whether the next token is nonterminal, just
        # look up an expansion rule either way and see if we can predict any
        rules.fetch(item.next, []).each do |rhs|
          next_item = Item.new(item.next, rhs, 0, pos, pos)
          skip = set.include?(next_item)
          debug "  predict: #{item.next} => #{next_item}#{" (skip)" if skip}" unless skip
          set << next_item unless skip
        end

        # similarly: ignore if the next token is nonterminal, we only care if
        # it appears in the input stream
        if input[pos] == item.next
          next_item = Item.new(item.lhs, item.rhs, item.dot + 1, item.start, pos + 1)
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

    debug "\nbuilding parse tree for #{input.map(&:to_s).join} from:"
    state_set.each.with_index do |set, i|
      next unless set && !set.empty?
      puts "=== #{i} ==="
      puts set.map(&:to_s).join("\n")
      puts
    end

    # completed state set for:
    # e => H
    # e => O
    # H => HO
    # H => OH
    # O => HH
    #
    # H O H
    #
    # === 0 ===
    #
    # === 1 ===
    # e -> H • (0) @ 1
    #
    # === 2 ===
    # H -> H O • (0) @ 2
    # e -> H • (0) @ 2
    #
    # === 3 ===
    # H -> O H • (1) @ 3
    # O -> H H • (0) @ 3
    # e -> O • (0) @ 3

    # starting with the `e` matching the whole input:
    #   e -> O • (0) @ 3
    # find an O starting at 0 ending at 3: O -> H H • (0)
    #  * find an H starting at 0:
    #    * the terminal H starts at 0
    #      * now, find an H starting at 1 ending at 3: H -> O H • (1) @ 3
    #        -> path: e -> O, O -> H H, H -> O H
    #    * the rule H -> H O • (0) @ 2
    #      * the terminal H starts at 0
    #        * find an O starting at 1, ending at 2
    #      * find an H starting at 0:
    #        * the rule H -> H O • (0) @ 2 (this rule): find an O starting at 3, ending at 2? no.
    #    * find an H starting at 0:
    #

    paths = []
    state_set.last.select { |item| item.complete? && item.start.zero? && item.lhs == "e" }.each do |top|
      path = []
      stack = [top, 0] # pair of earley item and offset into its rhs

      found = while (node = stack.pop)
        break false

      end

      paths << path if found
    end




    paths
  end
end

def part2(input)
  rules, input = input.split("\n\n", 2)
  rules = rules.split("\n").each_with_object(Hash.new) do |rule, hash|
    k, v = rule.strip.split(" => ", 2)
    hash[k] ||= []
    hash[k] << v.scan(ATOMS).to_a
  end
  # for this parser, everything can be considered a terminal *and possibly* a nonterminal too
  terminals = rules.to_a.flatten.uniq # .reject { |t| rules.keys.include?(t) }
  medicine = input.strip.scan(ATOMS).to_a

  parser = Earley.new(rules, debug: true)
  parser.parse(medicine, "e")


  # one at a time...

  # puts "reconstructing tree..."
  # now that we have a completed parse (hopefully!)
  # stack = [[top]]

  # while path = stack.pop
  #   item = path.last
  #   puts "#{path.map(&:to_s).join(", ")} : #{item}"
  #   left = item.start
  #   right = item.pos
  #   item.rhs.each do |sub|
  #     puts "  looking for completed #{sub} starting at #{left} ending at or before #{right}"
  #     left.upto(right) do |i|
  #       state_set[i].each do |candidate|
  #         puts "    #{candidate} #{candidate.complete?}"
  #       end
  #     end
  #   end
  # end

  # path, cost = search.path(start: medicine, goal: "e")
  # puts "path:"
  # puts path&.join("\n")
  # cost
end

part 1
with :part1
try ex1, expect: 4
try puzzle_input

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

XX
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
try ex2, expect: 3
try ex3, expect: 6
try ex4, expect: 1234
# try ex5, expect: 38
# try ex6, expect: 195
# try ex7, expect: 195
# try puzzle_input