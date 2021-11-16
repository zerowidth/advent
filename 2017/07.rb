require_relative "../toolkit"

def parse_tree(input)
  nodes = []
  weights = {}
  child_of = {}
  children_of = Hash.new { |h, k| h[k] = [] }

  input.lines.map do |line|
    raise "what? #{line.inspect}" unless line =~ /(\w+) \((\d+)\)(?: -> (.*))?/

    name = $1
    weight = $2.to_i
    nodes << name
    weights[name] = weight
    $3&.split(/, /)&.each do |child|
      children_of[name] << child
      child_of[child] = name
    end
  end

  # root is the only node that isn't a child
  root = nodes.detect { |n| child_of[n].nil? }
  make_node = lambda do |name|
    children = children_of[name].map { |c| make_node.call(c) }
    Node.new name, weights.fetch(name), children
  end
  nodes = make_node[root]

  yield Tree.new(nodes)
end

Node = Struct.new(:name, :weight, :children) do
  def weight_with_children
    @weight_with_children ||= weight + children.map(&:weight_with_children).sum
  end
end

class Tree
  attr_reader :root

  def initialize(root)
    @root = root
  end

  def unbalanced_diff
    return unless (node, expected = find_unbalanced(root))

    puts "#{node.name} should be #{expected} but is #{node.weight_with_children}"
    node.weight - (node.weight_with_children - expected)
  end

  def find_unbalanced(node)
    puts "checking #{node.name}"
    return nil unless node.children.any?

    by_weight = node.children.group_by(&:weight_with_children)
    return nil unless (unbalanced = by_weight.detect { |_w, cs| cs.length == 1 }&.last&.first)

    expected_weight = by_weight.detect { |_w, cs| cs.length > 1 }.first
    puts "#{unbalanced.name} is unbalanced, expected #{expected_weight}"
    find_unbalanced(unbalanced) || [unbalanced, expected_weight]
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
with(:parse_tree) { |tree| tree.root.name }
try example, "tknk"
try puzzle_input

part 2
with(:parse_tree, &:unbalanced_diff)
try example, 60
try puzzle_input
