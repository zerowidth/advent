require_relative "../toolkit"

def parse_steps(input)
  steps = Hash.of_set
  nodes = Set.new
  input.lines.map { |line| line.scan(/tep (\w)/) }.each do |before, after|
    nodes << before.first
    nodes << after.first
    steps[after.first] << before.first
  end
  (nodes - steps.keys).each do |done|
    steps[done] = Set.new # no prerequisites
  end
  steps
end

def part1(input)
  steps = parse_steps(input)

  complete = Set.new
  while complete.length < steps.length
    next_nodes = steps.select do |node, requirements|
      next if complete.include? node

      requirements.subset? complete
    end
    done = next_nodes.keys.min
    complete << done
  end

  complete.to_a.join
end

def duration(node)
  node.ord - 64 # A is 65
end

def part2(input, num_workers:, base_duration: 0)
  steps = parse_steps(input)

  t = 0
  complete = Set.new
  workers = Array.new(num_workers)
  while complete.length < steps.length
    # check if any worker has completed their task
    workers = workers.map do |worker|
      next if worker.nil?

      node, duration = *worker
      if duration == 1
        complete << node
        nil
      else
        [node, duration - 1]
      end
    end

    # assign work to available workers
    in_progress = workers.compact.map(&:first)
    available = steps.select do |node, requirements|
      !complete.include?(node) && !in_progress.include?(node) && requirements.subset?(complete)
    end.keys.sort

    workers = workers.map do |worker|
      if worker.nil? && (node = available.shift)
        [node, base_duration + duration(node)]
      else
        worker
      end
    end

    debug "t = #{t}: #{workers} complete #{complete.to_a}"
    t += 1
  end

  t - 1
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

part 2
with :part2, num_workers: 2
debug!
try ex1, expect: 15
no_debug!
with :part2, num_workers: 5, base_duration: 60
try puzzle_input
