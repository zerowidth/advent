require_relative "../toolkit"

def part1(input)
  weights = input.numbers.reverse
  target = weights.sum / 3
  puts "#{weights.length} weights, sum #{weights.sum}, target #{target}"

  best_len = weights.length
  first_groups = []
  1.upto(weights.length).each do |len|
    break if len >= best_len
    found = weights.combination(len).with_progress(title: "combinations of len #{len}").select do |group|
      group.sum == target
    end
    best_len = len if found.any?
    first_groups.concat(found)
  end
  puts "found #{first_groups.length} potential groupings"
  valid = first_groups.with_progress(title: "validating", length: true).select do |group|
    # find a valid second and third group
    rest = weights - group
    rest.all_combinations.any? do |second|
      second.sum == target && (rest - second).sum == target
    end
  end
  puts "found #{valid.length} valid groupings"

  best = valid.min_by do |group|
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
with :part1
try ex1, expect: 99
try puzzle_input

# part 2
# with :part2
# try ex1, expect: nil
# try puzzle_input
