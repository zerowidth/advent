require_relative "../toolkit"
require "set"

Prog = Struct.new(:name, :weight, :children, :parent)

def parse_tree(input)
  progs = Hash.new { |h, k| h[k] = [] }
  weights = {}
  input.lines.map do |line|
    if line =~ /(\w+) \((\d+)\)(?: -> (.*))?/
      name = $1
      progs[name] = []
      weights[name] = $2.to_i
      if $3
        $3.split(/, /).each do |child|
          progs[name] << child
        end
      end
    else
      puts "what? #{line.inspect}"
    end
  end
  [progs, weights]
end

def root(input)
  progs, _ = *parse_tree(input)
  supported = Set.new
  progs.each do |parent, children|
    children.each { |c| supported << c }
  end
  (Set.new(progs.keys) - supported).to_a.first
end

def find_wrong_weight(input)
  progs, weights = *parse_tree(input)
  final_weights = {}
  supported = Set.new
  progs.each do |parent, children|
    children.each { |c| supported << c }
  end
  root = (Set.new(progs.keys) - supported).to_a.first

  balance root, progs, weights
  x = $weight
  $weight = nil
  x
end

def balance(root, progs, weights)
  children = progs[root]
  # puts "balancing #{root}: #{children.inspect}"
  child_weights = children.map do |child|
    balance(child, progs, weights)
  end
  if children.size > 0
    if child_weights.uniq.size > 1
      puts "#{root} child weights: #{children.zip(child_weights).inspect}"
      counts = Hash[*child_weights.group_by{ |v| v }.flat_map{ |k, v| [k, v.size] }]
      expected = counts.detect {|k, v| v != 1}.first
      puts "#{root} expects all children with weight #{expected}"
      unbalanced = children.zip(child_weights).detect { |c, w| w != expected }
      puts "#{root} children unbalanced: child #{unbalanced.first}"
      unless $weight
        $weight = weights[unbalanced.first] - (unbalanced.last - expected)
      end
    else
      # puts "#{root} child weights: #{children.zip(child_weights).inspect} (balanced)"
    end
  end
  # puts "#{root} child weights = #{child_weights.inspect}"
  # if child_weights.uniq.size > 1
  # puts "#{root} : #{children.zip(child_weights).inspect}"
  # end
  # puts "#{root} returning #{weights[root]} + #{child_weights.sum}"
  weights[root] + child_weights.sum
end

example = <<-EX
pbga (66)
xhth (57)
ebii (61)
havc (66)
ktlj (57)
fwft (72) -> ktlj, cntj, xhth
qoyq (66)
padx (45) -> pbga, havc, qoyq
tknk (41) -> ugml, padx, fwft
jptl (61)
ugml (68) -> gyxo, ebii, jptl
gyxo (61)
cntj (57)
EX

part 1
with(:root)
try example, "tknk"
try puzzle_input

part 2
with(:find_wrong_weight)
# try "input", 0
try example, 60
try puzzle_input
