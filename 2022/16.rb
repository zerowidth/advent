require_relative "../toolkit"

State = Struct.new(:location, :time_remaining, :open_valves, :total_flow, :path)

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

  stack = [State.new("AA", 30, Set.new, 0, [])]
  best = nil
  n = 0
  while (node = stack.shift)
    n += 1
    debug "n #{n} stack #{stack.size} current #{node}" if n % 10000 == 0
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

  puts "found in #{n} iterations: #{best}"

  best&.total_flow
end

Location = Struct.new(:position, :time_remaining) do
  def move_to(new_position, cost)
    # self.class.new(new_position, time_remaining - cost, path + [new_position])
    self.class.new(new_position, time_remaining - cost)
  end

  def to_s
    "#{position}:#{time_remaining}"
  end
  alias_method :inspect, :to_s
end

P2State = Struct.new(:locations, :open_valves, :total_flow) do
  def id
    "#{locations.map(&:to_s).join(";")};#{open_valves.to_a.sort.join(";")}"
  end
end

def part2(input)
  edges, rates, costs, to_open = preprocess(input)

  stack = [P2State.new([Location.new("AA", 26), Location.new("AA", 26)], Set.new, 0)]
  best = nil
  n = 0
  skipped = 0
  seen = Set.new
  while (node = stack.shift)
    node_id = node.id
    if seen.include?(node_id)
      skipped += 1
      next
    end
    seen << node_id
    n += 1
    puts "n #{n} stack #{stack.size} skipped #{skipped} current #{node}" if n % 10000 == 0
    # debug "node: #{node}"

    if to_open.length == node.open_valves.length || node.locations.all? { |loc| loc.time_remaining <= 0 }
      if node.total_flow > (best&.total_flow || 0)
        puts "best so far: #{node}"
        best = node
      end
      next
    end

    still_closed = to_open - node.open_valves
    locations = node.locations # .sort_by(&:time_remaining).reverse
    locations.each.with_index do |loc, i|
      next if loc.time_remaining <= 0

      still_closed.each do |next_location|
        next if node.locations.any? { |l| l.position == next_location }
        cost = costs.fetch(loc.position).fetch(next_location) + 1 # move and open
        time_remaining = loc.time_remaining - cost
        next_locations = locations.dup
        next_locations[i] = loc.move_to(next_location, cost)
        stack << P2State.new(next_locations, node.open_valves + [next_location], node.total_flow + rates[next_location] * time_remaining)
      end
    end
  end

  puts "found in #{n} iterations: #{best}"

  best&.total_flow
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
