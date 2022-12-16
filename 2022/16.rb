require_relative "../toolkit"

State = Struct.new(:location, :time_remaining, :open_valves, :total_flow, :path) do
  def id
    "#{location}-#{time_remaining}-#{open_valves.sort.join(",")}-#{total_flow}"
  end
end

def preprocess(input)
  edges = {}
  rates = {}
  input.lines.each do |line|
    line.scan(/Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.*)/).map do |name, rate, tunnels|
      others = tunnels.split(", ")
      edges[name] = others
      rates[name] = rate.to_i
    end
  end

  costs = Hash.of_hash

  debug "pregenerating path costs"
  edges.keys.each do |from|
    (edges.keys - [from]).each do |to|
      # break unless costs[from][to].nil?
      # debug "finding cost from #{from} to #{to}"
      visited = Set.new
      stack = [[from, 0]]
      while (current = stack.shift)
        node, cost = *current
        # debug "  node #{node} cost #{cost}"
        visited << node

        if node == to
          # debug "  found path from #{from} to #{to}: #{cost}"
          costs[from][to] = cost
          costs[to][from] = cost
          break
        end

        edges[node].each do |next_node|
          unless visited.include?(next_node)
            stack << [next_node, cost + 1]
          end
        end
      end
    end
  end
  # debug "costs:\n#{costs.pretty_inspect}"
  to_open = Set.new(edges.keys.select { |k| rates[k] > 0 })

  [edges, rates, costs, to_open]
end

def part1(input)
  edges, rates, costs, to_open = preprocess(input)

  uniques = Hash.new(0)
  stack = [State.new("AA", 30, Set.new, 0, [])]
  best = nil
  n = 0
  while (node = stack.shift)
    n += 1
    debug "n #{n} stack #{stack.size} current #{node}" if n % 10000 == 0
    uniques[node.id] += 1
    # debug "node: #{node}"

    # are we out of time or is everything on?
    closed = to_open - node.open_valves
    if node.time_remaining == 0 || closed.empty?
      # debug "  out of time or all valves are open #{node}"
      if node.total_flow > (best&.total_flow || 0)
        debug "best so far: #{node}"
        best = node
      end
      next
    end

    # should we open this valve? always do so if possible for now, might need to branch later
    if rates[node.location] > 0 && closed.include?(node.location)
      # debug "  opening valve #{node.location}"
      stack << State.new(node.location, node.time_remaining - 1, node.open_valves + [node.location],
                         node.total_flow + rates[node.location] * (node.time_remaining - 1), node.path + ["open #{node.location}"])
      next
    end

    closed.each do |next_location|
      from_costs = costs.fetch(node.location)
      cost = from_costs&.fetch(next_location)
      time_remaining = node.time_remaining - cost
      next if time_remaining < 0
      stack << State.new(next_location, time_remaining, node.open_valves, node.total_flow, node.path + [next_location])
    end
  end

  # for general dynamic programming info: can we save work by reusing state? seems like no.
  puts "uniques: #{uniques.size} #{uniques.values.sum}"

  best&.total_flow
end

def part2(input)
  input.lines
end

ex1 = <<EX
Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II
EX

part 1
with :part1
debug!
try ex1, 1651
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, 1707
no_debug!
try puzzle_input
