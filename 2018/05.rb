require_relative "../toolkit"

def react(polymer, title: nil)
  polymer = polymer.chars.to_a

  bar = progress_bar(title: title) unless debug?
  stack = []
  until polymer.empty?
    char = polymer.shift
    prev_char = stack.last
    if char != prev_char && (char.upcase == prev_char || char.downcase == prev_char)
      debug "  removing #{prev_char}#{char}"
      stack.pop
    else
      stack << char
    end
    bar.advance unless debug?
  end
  bar.finish unless debug?

  stack
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
    unit = "#{unit}|#{unit.upcase}"
    pattern = Regexp.new(unit)
    length = react(polymer.gsub(pattern, ""), title: "unit #{unit}").length
    by_unit[unit] = length
    debug "unit #{unit}: #{length}"
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
