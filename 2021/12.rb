require_relative "../toolkit"

def part1(input)
  nodes = Hash.of_array
  input.lines.each do |line|
    node, neighbor = line.split "-"
    nodes[node] << neighbor
    nodes[neighbor] << node
  end

  found = paths(nodes, "start", ["start"]) do |node, visited|
    nodes[node].select do |c|
      c =~ /[A-Z]/ || (c =~ /[a-z]/ && !visited.include?(c))
    end
  end
  found&.length
end

def part2(input)
  nodes = Hash.of_array
  input.lines.each do |line|
    node, neighbor = line.split "-"
    nodes[node] << neighbor
    nodes[neighbor] << node
  end

  small_caves = nodes.values.flatten.uniq.grep(/[a-z]/)
  found = paths(nodes, "start", ["start"]) do |node, so_far|
    small_counts = so_far.tally.slice(*small_caves)

    # we can revisit a candidate if:
    # * it's a big cave
    # * it's a small unvisited cave
    # * it's a small cave that has only been visited once, and no others have been visited twice
    nodes[node].select do |c|
      next if c == "start"
      next true if c =~ /[A-Z]/

      small_counts.fetch(c, 0).zero? ||
        (small_counts[c] == 1 && small_counts.values.all? { |v| v < 2 })
    end
  end
  found.length
end

def paths(nodes, node, so_far, &neighbors)
  debug (" " * so_far.length) + "#{node} | so far #{so_far}" if debug?
  return [so_far] if node == "end"

  candidates = neighbors.call(node, so_far)
  return nil unless candidates.any?

  debug (" " * so_far.length) + "  recurse to #{candidates}" if debug?
  found = candidates.flat_map do |candidate|
    paths(nodes, candidate, so_far + [candidate], &neighbors)
  end.compact
  debug (" " * so_far.length) + "  #{node} -> #{candidates} returned: #{found}" if debug?
  found
end

ex1 = <<EX
start-A
start-b
A-c
A-b
b-d
A-end
b-end
EX

ex2 = <<EX
dc-end
HN-start
start-kj
dc-start
dc-HN
LN-dc
HN-end
kj-sa
kj-HN
kj-dc
EX

ex3 = <<EX
fs-end
he-DX
fs-he
start-DX
pj-DX
end-zg
zg-sl
zg-pj
pj-he
RW-he
fs-DX
pj-RW
zg-RW
start-pj
he-WI
zg-he
pj-fs
start-RW
EX

part 1
with :part1
debug!
try ex1, 10
try ex2, 19
no_debug!
try ex3, 226
try puzzle_input

part 2
with :part2
debug!
try ex1, 36
no_debug!
try ex2, 103
try ex3, 3509
try puzzle_input
