require_relative "../toolkit"
require "set"

Prog = Struct.new(:name, :weight, :children, :parent)

def parse_tree(input)
  nodes_by_name = {}
  parents = {}
  children_by_name = Hash.new { |h, k| h[k] = [] }
  weights = {}
  input.lines.map do |line|
    if line =~ /(\w+) \((\d+)\)(?: -> (.*))?/
      name = $1
      weight = $2.to_i
      nodes_by_name[name] = Node.new name, weight
      if $3
        $3.split(/, /).each do |child|
          parents[child] = name
          children_by_name[name] << child
        end
      end
    else
      puts "what? #{line.inspect}"
    end
  end

  puts "parents:"
  pp parents
  puts "children:"
  pp children_by_name

  bottom = children_by_name.keys.detect { |k| parents[k] == nil }
  puts "bottom #{bottom}"



  # yield Tree.new(nodes, weights)

  nil
end

Node = Struct.new(:name, :weight, :children) do
  def weight_with_children
    children.map(&:weight_with_children).sum
  end
end

class Tree
  attr_reader :root

  def initialize(nodes, weights)
    @nodes = nodes
    @node_weights = weights
    @weights = {}
    @root = find_root
    save_weight_for(@root)
  end

  def find_root
    supported = Set.new
    @nodes.each do |parent, children|
      children.each { |c| supported << c }
    end
    (Set.new(@nodes.keys) - supported).to_a.first
  end

  def unbalanced_diff
    node, expected = *find_unbalanced(root)
    child_weights = @nodes[node].map {|c| @weights[c] }.sum
    weight = @node_weights[node]
    puts "#{node} should be #{expected} but is #{weight + child_weights}"
    weight - (weight + child_weights - expected)
  end

  def save_weight_for(node)
    weight = @node_weights[node] + @nodes[node].map { |child| save_weight_for(child) }.sum
    @weights[node] = weight
    weight
  end

  def find_unbalanced(node)
    puts "checking #{node}"
    if children = @nodes[node]
      weights = children.map { |c| @weights[c] }
      count_by_weight = Hash[*weights.group_by{|v|v}.flat_map {|w,c| [c.length, w]}]
      if odd_one_out = children.zip(weights).detect {|c,w| w == count_by_weight[1]}
        odd_one_out = odd_one_out.first
        puts "#{node} children has odd one out: #{odd_one_out}"
        expected = count_by_weight.detect {|c, w| c != 1 }.last
        return find_unbalanced(odd_one_out) || [odd_one_out, expected]
      else
        puts "#{node}: children balanced"
      end
    end
    nil
  end
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
with(:parse_tree) { |t| t.root }
try example, "tknk"
# try puzzle_input

# part 2
# with(:parse_tree) { |t| t.unbalanced_diff }
# try example, 60
# try puzzle_input
