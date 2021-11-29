require_relative "../toolkit"

def part1(input)
  rules = Hash.of_set
  nodes = Set.new
  input.lines.map { |line| line.scan(/tep (\w)/) }.each do |before, after|
    nodes << before.first
    nodes << after.first
    rules[after.first] << before.first
  end
  (nodes - rules.keys).each do |done|
    rules[done] = Set.new # no prerequisites
  end

  complete = Set.new
  while complete.length < nodes.length
    next_nodes = rules.select do |node, requirements|
      next if complete.include? node

      requirements.subset? complete
    end
    done = next_nodes.keys.sort.first
    complete << done
  end

  complete.to_a.join
end

ex1 = <<-EX
Step C must be finished before step A can begin.
Step C must be finished before step F can begin.
Step A must be finished before step B can begin.
Step A must be finished before step D can begin.
Step B must be finished before step E can begin.
Step D must be finished before step E can begin.
Step F must be finished before step E can begin.
EX

part 1
with :part1
debug!
try ex1, expect: "CABDFE"
# no_debug!
try puzzle_input
# NOT UBDLSXKYZIMNTFGWJVPOHRQ
# NOT ABDLSXKYZIMNTFGWJVPOHRQ
# NOT ACEUBDLSXKYZIMNTFGWJVPOHRQ

# part 2
# with :part2
# debug!
# try ex1, expect: nil
# no_debug!
# try puzzle_input
