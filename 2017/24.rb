require_relative "../toolkit"

def bridges(input)
  ports = input.lines.map do |line|
    line.strip.split("/").map(&:to_i)
  end

  bridges = []
  ports.each do |start|
    next unless start.any? {|s| s == 0}
    available = ports.dup
    available.delete(start)
    bridges += build([start], start.max, available)
  end

  bridges.each do |b|
    show b
  end
  bridges
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

    available = ports.dup
    available.delete candidate
    nextval = first ? candidate[1] : candidate[0]
    built += build(bridge + [candidate], nextval, available)
  end

  built
end

def max_score(bridges)
  scores = bridges.map do |bridge|
    bridge.map(&:sum).sum
  end

  bridges.zip(scores).sort_by(&:last).last
end

def max_len(bridges)
  sorted = bridges.zip(bridges.map(&:length)).sort_by(&:last)
  sorted.select { |b, l| l == sorted.last.last }
end

def show(bridge)
  bridge.map { |bi| bi.map(&:to_s).join("/") }.join("--")
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

# part 1
# with(:bridges) { |bs| b, s = *max_score(bs); puts "max is #{show(b)}"; s }
# try example, 31
# try puzzle_input

generated = bridges(puzzle_input)
# generated = bridges(example)

part 1
strongest, score = *max_score(generated)
puts "strongest is #{show(strongest)} with score #{score}"

part 2
longest = max_len(generated)
puts "longest bridges:"
longest.each do |b, s|
  puts "#{show(b)}: #{s}"
end
strongest, score = *max_score(longest.map(&:first))
puts "strongest is #{show(strongest)} with score #{score}"


# part 2
# with(:solution)
# try example, 0
# try puzzle_input
