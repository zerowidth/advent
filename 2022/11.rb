require_relative "../toolkit"

class Monkey
  def self.parse(lines)
    id = lines.shift.scan(/Monkey (\d+):/).first.first.to_i
    items = lines.shift.scan(/Starting items: (.+)/).first.first.split(", ").map(&:to_i)
    operation = lines.shift.scan(/new = (.*)/).first.first
    divisible_by = lines.shift.scan(/divisible by (\d+)/).first.first.to_i
    if_true = lines.shift.scan(/monkey (\d+)/).first.first.to_i
    if_false = lines.shift.scan(/monkey (\d+)/).first.first.to_i
    new(id, items, operation, divisible_by, if_true, if_false)
  end

  attr_reader :divisible_by, :items, :inspections

  def initialize(id, items, operation, divisible_by, if_true, if_false)
    @id = id
    @items = items
    @operation = operation
    singleton_class.class_eval "def new_value(old)\n#{operation}\nend", __FILE__, __LINE__
    @divisible_by = divisible_by
    @if_true = if_true
    @if_false = if_false
    @inspections = 0
  end

  def turn(divide: false)
    results = []
    debug "monkey #{@id}"

    while (old = items.shift)
      @inspections += 1
      debug "  inspect #{old}"
      old = new_value(old) # eval "old = #{@operation}"
      debug "    #{@operation}, now #{old}"
      if divide
        old /= 3
        debug "  / 3 is #{old}"
      end
      if (old % @divisible_by) == 0
        debug "    divisible by #{@divisible_by}, throw to #{old} to #{@if_true}"
        results << [old, @if_true]
      else
        debug "    not divisible by #{@divisible_by}, throw #{old} to #{@if_false}"
        results << [old, @if_false]
      end
    end

    results
  end
end

def part1(input)
  monkeys = input.sections.map { |s| Monkey.parse(s.lines) }
  debug monkeys[0].new_value(1)

  20.times do
    monkeys.each do |monkey|
      monkey.turn(divide: true).each do |item, to|
        monkeys[to].items << item
      end
    end
  end

  monkeys.each.with_index do |m, i|
    debug "monkey #{i} has #{m.items}"
  end

  monkeys.map(&:inspections).sort.last(2).reduce(:*)
end

def part2(input, times: 20)
  monkeys = input.sections.map { |s| Monkey.parse(s.lines) }
  debug monkeys[0].new_value(1)

  puts monkeys.map(&:divisible_by)
  multiple = monkeys.map(&:divisible_by).uniq.reduce(:*)

  times.times do
    monkeys.each do |monkey|
      monkey.turn(divide: false).each do |item, to|
        monkeys[to].items << (item % multiple)
      end
    end
  end

  monkeys.each.with_index do |m, i|
    debug "monkey #{i} has #{m.inspections} inspections"
  end

  monkeys.map(&:inspections).sort.last(2).reduce(:*)
end

ex1 = <<EX
Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

Monkey 1:
  Starting items: 54, 65, 75, 74
  Operation: new = old + 6
  Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

Monkey 2:
  Starting items: 79, 60, 97
  Operation: new = old * old
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

Monkey 3:
  Starting items: 74
  Operation: new = old + 3
  Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1
EX

part 1
with :part1
debug!
try ex1, 10605
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, 10197
no_debug!
with :part2, times: 10_000
try ex1, 2713310158
try puzzle_input
