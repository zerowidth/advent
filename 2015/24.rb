require_relative "../toolkit"

# Returns the smallest possible groups that can be split evenly.
# Only returns the first set of groups with the shortest length.
def equal_weights(weights, num_groups, progress: false)
  return weights if num_groups == 1

  target = weights.sum / num_groups
  Enumerator.new do |y|
    1.upto(weights.length).each do |len|
      combinations = weights.combination(len)
      combinations = combinations.to_a.with_progress(title: "combinations of len #{len}", length: true) if progress
      found = combinations.select do |group|
        # skip recursion if we can, it saves some time
        group.sum == target &&
          (num_groups <= 2 || equal_weights(weights - group, num_groups - 1).any?)
      end
      found.each { |f| y << f }
      break if found.any?
    end
  end
end

def best_equal_groupings(input, num_groups = 3)
  weights = input.numbers
  target = weights.sum / num_groups
  puts "#{weights.length} weights, sum #{weights.sum}, target #{target}"

  groups = equal_weights(weights, num_groups, progress: true).to_a
  puts "found #{groups.length} groupings"

  best = groups.min_by do |group|
    [group.length, group.reduce(1, &:*)]
  end
  puts "best group: #{best.inspect}"
  best.reduce(1, &:*)
end

ex1 = <<-EX
1
2
3
4
5
7
8
9
10
11
EX

part 1
with :best_equal_groupings, 3
try ex1, expect: 99
try puzzle_input

part 2
with :best_equal_groupings, 4
try ex1, expect: 44
try puzzle_input
