require_relative "../toolkit"

def solution(input)
  costs = {}
  cities = []
  input.lines.map do |line|
    if line =~ /(\w+) to (\w+) = (\d+)/
      cities << $1 << $2
      costs[[$1, $2].sort] = $3.to_i
    end
  end
  cities = cities.uniq

  path_costs = cities.permutation.map do |cs|
    cost = 0
    cs.each_cons(2) do |pair|
      cost += costs[pair.sort]
    end
    # puts cs.join(" -> ") + " = #{cost}"
    cost
  end

  yield path_costs
end

part 1
with(:solution) { |pc| pc.min }

example = <<-S
London to Dublin = 464
London to Belfast = 518
Dublin to Belfast = 141
S

try example, 605
try puzzle_input

part 2
with(:solution) { |pc| pc.max }
try example, 982
try puzzle_input
