require_relative "../toolkit"

def read_rules(input)
  rules = {}
  input.each_line do |line|
    num, rest = line.split(":")
    if rest =~ /"(\w+)"/
      rules[num] = [$1]
    else
      rules[num] = rest.split("|").map(&:split)
    end
  end

  rules
end

def cyk(input, rules, root)
  set = Set.new # P[l, s, v] substring of length l starting from s can use nonterminal v

  ones = []
  twos = []
  rules.each do |lhs, rhs|
    rhs.each do |production|
      case production.length
      when 1
        ones << [lhs, production]
      when 2
        twos << [lhs] + production
      else
        raise "not chomsky normal form: #{lhs} -> #{production}"
      end
    end
  end

  0.upto(input.length - 1) do |s|
    ones.each do |v, a|
      set << [1, s, v] if input[s] == a
    end
  end

  2.upto(input.length) do |l| # length of substring
    # debug "span #{l}" if debug?
    # dpp set if debug?
    0.upto(input.length - l) do |s| # start of substring
      1.upto(l - 1) do |p| # length of substring
        twos.each do |a, b, c|
          match = set.include?([p, s, b]) && set.include?([l - p, s + p, c])
          debug "  #{a} -> #{b} #{c}: start #{s} partition #{p}" if match && debug?
          set << [l, s, a] if match
        end
      end
    end
  end

  set.include? [input.length, 0, root]
end

def part1_cyk(input)
  rules, inputs = input.split("\n\n", 2)
  rules = read_rules(rules)
  dpp rules
  inputs = inputs.split("\n").map(&:chomp).map(&:chars)
  inputs.with_progress(total: inputs.length).select do |i|
    pass = cyk(i, rules, "0")
    debug "#{i.join}: #{pass ? "pass" : "fail"}"
    pass
  end.size
end

# manually rewritten to chomsky normal form (added rule 6)
ex1 = <<-EX
0: 4 6
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: "a"
5: "b"
6: 1 5

ababbb
bababa
abbbab
aaabbb
aaaabbb
EX

part 1
with :part1_cyk
debug!
try ex1, expect: 2
# no_debug!
# try puzzle_input

# part 2
# with :part2
# try ex1, expect: nil
# try puzzle_input
