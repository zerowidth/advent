require_relative "../toolkit"

def react(polymer)
  letters = polymer.downcase.chars.uniq
  pattern = letters.sort.map { |l| "#{l}#{l.upcase}|#{l.upcase}#{l}" }.join("|")
  pattern = Regexp.new(pattern)

  bar = progress_bar unless debug?
  while polymer.gsub!(pattern, "")
    bar.advance unless debug?
    # noop
  end
  bar.finish unless debug?

  polymer
end


def part1(input)
  polymer = input.chomp
  react(polymer).length
end

def part2(input)
  polymer = input.chomp
  units = polymer.downcase.chars.uniq

  by_unit = {}
  units.each do |unit|
    pattern = Regexp.new("#{unit}|#{unit.upcase}")
    length = react(polymer.gsub(pattern, "")).length
    by_unit[unit] = length
    debug "unit #{pattern}: #{length}"
  end

  by_unit.min_by(&:last).last
end

ex1 = <<-EX
dabAcCaCBAcCcaDA
EX

part 1
with :part1
debug!
try ex1, expect: 10
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, expect: 4
no_debug!
try puzzle_input
