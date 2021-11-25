require_relative "../toolkit"
require_relative "../earley"

def read_rules(input)
  rules = {}
  input.each_line do |line|
    num, rest = line.split(":")
    if rest =~ /"(\w+)"/
      rules[num] = [[$1]]
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
        ones << [lhs] + production
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

def part1_earley(input)
  rules, inputs = input.split("\n\n", 2)
  rules = read_rules(rules)
  dpp rules

  inputs = inputs.split("\n").map(&:chomp).map(&:chars)

  parser = Earley.new(rules)
  inputs.with_progress(total: inputs.length).select do |i|
    tree = parser.parse(i, "0")
    debug "#{i.join}: #{tree ? "pass" : "fail"}"
    tree
  end.size
end

def part2(input)
  rules, inputs = input.split("\n\n", 2)
  rules = read_rules(rules)

  # but: rewrite rules:
  # 8: 42 | 42 8
  # 11: 42 31 | 42 11 31
  rules["8"] = [["42"], ["42", "8"]]
  rules["11"] = [["42", "31"], ["42", "11", "31"]]

  dpp rules

  inputs = inputs.split("\n").map(&:chomp).map(&:chars)

  parser = Earley.new(rules)
  inputs.with_progress(total: inputs.length).select do |i|
    tree = parser.parse(i, "0")
    debug "#{i.join}: #{tree ? "pass" : "fail"}"
    tree
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

# original example input, not chomsky
ex2 = <<EX
0: 4 1 5
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: "a"
5: "b"

ababbb
bababa
abbbab
aaabbb
aaaabbb
EX

ex3 = <<EX
42: 9 14 | 10 1
9: 14 27 | 1 26
10: 23 14 | 28 1
1: "a"
11: 42 31
5: 1 14 | 15 1
19: 14 1 | 14 14
12: 24 14 | 19 1
16: 15 1 | 14 14
31: 14 17 | 1 13
6: 14 14 | 1 14
2: 1 24 | 14 4
0: 8 11
13: 14 3 | 1 12
15: 1 | 14
17: 14 2 | 1 7
23: 25 1 | 22 14
28: 16 1
4: 1 1
20: 14 14 | 1 15
3: 5 14 | 16 1
27: 1 6 | 14 18
14: "b"
21: 14 1 | 1 14
25: 1 1 | 1 14
22: 14 14
8: 42
26: 14 22 | 1 20
18: 15 15
7: 14 5 | 1 21
24: 14 1

abbbbbabbbaaaababbaabbbbabababbbabbbbbbabaaaa
bbabbbbaabaabba
babbbbaabbbbbabbbbbbaabaaabaaa
aaabbbbbbaaaabaababaabababbabaaabbababababaaa
bbbbbbbaaaabbbbaaabbabaaa
bbbababbbbaaaaaaaabbababaaababaabab
ababaaaaaabaaab
ababaaaaabbbaba
baabbaaaabbaaaababbaababb
abbbbabbbbaaaababbbbbbaaaababb
aaaaabbaabaaaaababaa
aaaabbaaaabbaaa
aaaabbaabbaaaaaaabbbabbbaaabbaabaaa
babaaabbbaaabaababbaabababaaab
aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba
EX

part 1
with :part1_cyk # too slow!
no_debug!
try ex1, expect: 2
with :part1_earley
debug!
try ex2, expect: 2
no_debug!
try puzzle_input

part 2
with :part1_earley
try ex3, expect: 3
with :part2
try ex3, expect: 12
try puzzle_input
