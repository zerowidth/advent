require_relative "../toolkit"

def part1(input, iterations:)
  template, subs = input.sections
  subs = subs.lines.flat_map { |line| line.scan(/(\w+) -> (\w)/) }.to_h
  subs = subs.transform_keys(&:chars)

  poly = template.chars
  iterations.times_with_progress do
    next_poly = poly.each_cons(2).flat_map do |pair|
      if (c = subs[pair])
        [pair.first, c]
      else
        [c]
      end
    end
    poly = next_poly + [poly.last]
  end
  counts = poly.tally
  counts.values.max - counts.values.min
end

def part2(input, iterations:)
  template, rules = input.sections
  rules = rules.lines.flat_map { |line| line.scan(/(\w+) -> (\w)/) }
  subs = {}
  rules.each do |lhs, rhs|
    pair = lhs.chars
    subs[lhs] = [[pair.first, rhs].join, [rhs, pair.last].join]
  end

  debug "subs:\n#{subs.pretty_inspect}"

  counts = template.chars.each_cons(2).map(&:join).tally
  counts.default = 0

  iterations.times do
    next_counts = Hash.new(0)
    counts.each do |pair, count|
      subs[pair].each do |sub|
        next_counts[sub] += count
      end
    end
    counts = next_counts
  end

  tally = Hash.new(0)
  counts.each do |pair, count|
    tally[pair.chars.first] += count
  end
  tally[template.chars.last] += 1
  debug "tally:\n#{tally.sort_by(&:last).to_h.pretty_inspect}"
  # debug "tally.values.sum: #{tally.values.sum}"
  (tally.values.max - tally.values.min)
end

ex1 = <<EX
NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C
EX

# from dylan-smith's puzzle input
ex2 = <<EX
NBOKHVHOSVKSSBSVVBCS

SN -> H
KP -> O
CP -> V
FN -> P
FV -> S
HO -> S
NS -> N
OP -> C
HC -> S
NP -> B
CF -> V
NN -> O
OS -> F
VO -> V
HK -> N
SV -> V
VC -> V
PH -> K
NH -> O
SB -> N
KS -> V
CB -> H
SS -> P
SP -> H
VN -> K
VP -> O
SK -> V
VF -> C
VV -> B
SF -> K
HH -> K
PV -> V
SO -> H
NK -> P
NO -> C
ON -> S
PB -> K
VS -> H
SC -> P
HS -> P
BS -> P
CS -> P
VB -> V
BP -> K
FH -> O
OF -> F
HF -> F
FS -> C
BN -> O
NC -> F
FC -> B
CV -> V
HN -> C
KF -> K
OO -> P
CC -> S
FF -> C
BC -> P
PP -> F
KO -> V
PC -> B
HB -> H
OB -> N
OV -> S
KH -> B
BO -> B
HV -> P
BV -> K
PS -> F
CH -> C
SH -> H
OK -> V
NB -> K
BF -> S
CO -> O
NV -> H
FB -> K
FO -> C
CK -> P
BH -> B
OH -> F
KB -> N
OC -> K
KK -> O
CN -> H
FP -> K
VH -> K
VK -> P
HP -> S
FK -> F
BK -> H
KV -> V
BB -> O
KC -> F
KN -> C
PO -> P
NF -> P
PN -> S
PF -> S
PK -> O
EX

part 1
with :part1, iterations: 1
debug!
# try ex1, 1588
try ex2, 8
# no_debug!
# try puzzle_input

part 2
with :part2, iterations: 1
debug!
# try ex1, 1588
try ex2, 8
with :part2, iterations: 40
no_debug!
try ex1, 2188189693529
try ex2, 3776553567525
try puzzle_input # not 2544407633816
