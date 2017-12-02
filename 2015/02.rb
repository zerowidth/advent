require_relative "../toolkit"

def package_totals(input, &block)
  input.lines.
    map { |line| line.split("x").map(&:to_i) }.
    map(&block).
    sum
end

def area_for_package(dimensions)
  areas = dimensions.combination(2).map { |x, y| x * y }
  paper = areas.map { |a| a * 2 }.sum
  slack = areas.min
  paper + slack
end

def ribbon_for_package(dimensions)
  perimeters = dimensions.combination(2).map { |x, y| 2*x + 2*y }
  volume = dimensions.inject(1, &:*)
  perimeters.min + volume
end

with(:package_totals) { |dimensions| area_for_package dimensions }
try "2x3x4", 58
try "1x1x10", 43
try puzzle_input

with(:package_totals) { |dimensions| ribbon_for_package dimensions }
try "2x3x4", 34
try "1x1x10", 14
try puzzle_input
