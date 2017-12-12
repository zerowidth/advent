require_relative "../toolkit"
require "set"

def solution(input)
  graph = Hash.new { |h, k| h[k] = Set.new }

  input.lines.map do |line|
    _, pid, conns = */^(\d+) <-> (.*)/.match(line)
    if pid
      pid = pid.to_i
      conns = conns.split(", ").map(&:to_i)

      all = [pid] + conns
      all.each do |p|
        all.each { |q| graph[p] << q }
      end
    end
  end

  groups = {}
  graph.keys.each do |k|
    groups[k] = walk graph, Set.new, k
  end
  if block_given?
    yield groups
  else
    groups
  end
end

def walk(graph, set, pid)
  graph[pid].each do |q|
    if !set.include?(q)
      set << q
      walk graph, set, q
    end
  end
  set
end

example = <<-EX
0 <-> 2
1 <-> 1
2 <-> 0, 3, 4
3 <-> 2, 4
4 <-> 2, 3, 6
5 <-> 6
6 <-> 4, 5
EX

part 1
with(:solution) { |g| g[0].size }
try example, 6
try puzzle_input

part 2
with(:solution) { |gs| gs.values.uniq.size }
try example, 2
try puzzle_input
