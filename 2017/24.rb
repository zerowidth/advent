require_relative "../toolkit"

@bridges = {}
def gen_bridges(input)
  if (bs = @bridges[input])
    return block_given? ? yield(bs) : bs
  end

  ports = input.lines.map do |line|
    line.strip.split("/").map(&:to_i)
  end

  bridges = []
  ports.each do |start|
    next unless start.any? { |s| s == 0 }

    available = Set.new(ports.dup) - [start]
    bridges += build([start], start.max, available)
  end

  bridges.each do |b|
    show b if $debug
  end

  @bridges[input] = bridges
  block_given? ? yield(bridges) : bridges
end

def build(bridge, value, ports)
  built = [bridge]
  ports.select do |candidate|
    first = second = false
    if candidate[0] == value
      first = true
    elsif candidate[1] == value
      second = true
    end
    next unless first || second

    available = ports - [candidate]
    nextval = first ? candidate[1] : candidate[0]
    built += build(bridge + [candidate], nextval, available)
  end

  built
end

def max_score(bridges)
  scores = bridges.map do |bridge|
    bridge.map(&:sum).sum
  end

  bridges.zip(scores).max_by(&:last)
end

def max_len(bridges)
  len = bridges.sort_by(&:length).last.length
  best = bridges.select { |b| b.length == len }.sort_by { |b| b.map(&:sum).sum }.last
  [best, best.map(&:sum).sum]
end

def show(bridge)
  puts bridge.map { |bi| bi.map(&:to_s).join("/") }.join("--")
end

def part1(input)
  bridges = gen_bridges(input)
  bridge, score = *max_score(bridges)
  show bridge
  score
end

def part2(input)
  bridges = gen_bridges(input)
  bridge, score = *max_len(bridges)
  show bridge
  score
end

example = <<-EX
0/2
2/2
2/3
3/4
3/5
0/1
10/1
9/10
EX

part 1
with :part1
debug!
try example, 31
no_debug!
try puzzle_input

part 2
with(:part2)
try example, 19
try puzzle_input
