require_relative "../toolkit"

class Rule
  attr_reader :name, :ranges

  def initialize(name, ranges)
    @name = name
    @ranges = ranges
  end

  def valid?(input)
    ranges.any? { |range| range.include? input }
  end

  def to_s
    "#{name}: #{ranges.map(&:to_s).join(", ")}"
  end

  def inspect
    "<#{self}>"
  end
end

def parse(input)
  parts = input.split("\n\n")

  rules = parts[0].each_line.map do |line|
    name = line.split(":").first
    ranges = line.scan(/(\d+)-(\d+)/).map do |a, b|
      Range.new(a.to_i, b.to_i)
    end
    Rule.new(name, ranges)
  end
  ticket = parts[1].numbers
  nearby = parts[2].each_line.drop(1).map(&:numbers)

  [rules, ticket, nearby]
end

def part1(input)
  rules, _ticket, nearby = *parse(input)

  # find tickets with values that are not valid for any field
  nearby.flat_map do |ticket|
    debug "checking #{ticket}"
    invalid = ticket.reject do |number|
      rules.any? { |rule| rule.valid?(number) }
    end
    debug "  #{invalid}"
    invalid
  end.sum
end

def part2(input)
  rules, ticket, nearby = *parse(input)

  # find tickets with valid fields
  valid = nearby.reject do |n|
    invalid = n.reject do |number|
      rules.any? { |rule| rule.valid?(number) }
    end
    invalid.any?
  end

  puts "#{valid.length} valid tickets, rejected #{nearby.length - valid.length} tickets"

  # given all valid tickets, and all the rules:
  # figure out which field on each ticket matches only one rule
  matched = Hash.new { |h, k| h[k] = Set.new }
  fields = Set.new(0...ticket.length)

  rules.each do |rule|
    debug "examining #{rule}"
    fields.each do |field|
      if valid.all? { |t| rule.valid? t[field]}
        debug "  matched on field #{field}"
        matched[field] << rule
      end
    end
  end

  # now that we have potential matches, iterate to simplify: if any field has
  # only one rule, it can't be in any other field too
  solved = Set.new
  matched.length.times do |iteration|
    if solved.length == rules.length
      debug "breaking on iteration #{iteration}, solved!"
      break
    end

    debug "iteration: #{iteration}"
    matched.each do |field, rules|
      next unless rules.length == 1 && !solved.include?(rules.first)

      rule = rules.first
      solved << rule
      debug "removing #{rule.name} from #{fields - [field]}"
      (fields - [field]).each { |f| matched[f].delete(rule) }
    end
  end
  raise if matched.values.any? { |v| v.length > 1 }

  pp matched

  solved = {}
  matched.each do |field, rules|
    solved[rules.first.name] = ticket[field]
  end

  dpp solved

  solved
end

ex1 = <<-EX
class: 1-3 or 5-7
row: 6-11 or 33-44
seat: 13-40 or 45-50

your ticket:
7,1,14

nearby tickets:
7,3,47
40,4,50
55,2,20
38,6,12
EX

ex2 = <<EX
class: 0-1 or 4-19
row: 0-5 or 8-19
seat: 0-13 or 16-19

your ticket:
11,12,13

nearby tickets:
3,9,18
15,1,5
5,14,9
EX

part 1
with :part1
debug!
try ex1, expect: 71
no_debug!
try puzzle_input

part 2
debug!
with :part2
try(ex2, expect: 12) { |ticket| ticket["class"] }
try(ex2, expect: 11) { |ticket| ticket["row"] }
try(ex2, expect: 13) { |ticket| ticket["seat"] }
no_debug!
try(puzzle_input) { |ticket| ticket.select { |n, _v| n =~ /\Adeparture/ }.map(&:last).reduce(1, &:*) }
