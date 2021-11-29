require_relative "../toolkit"

def part1(input)
  _i, metadata = read_metadata input.numbers, 0
  metadata.sum
end

def part2(input)
  _i, root = Node.read_tree input.numbers
  debug "root: #{root}"
  node_value(root)
end

# returns last index read and an array of metadata
def read_metadata(input, i)
  num_children = input[i]
  num_metadata = input[i + 1]

  debug "reading #{num_children} and #{num_metadata}"
  start = i + 2
  metadata = []

  # recurse: read children and their metadata
  num_children.times do
    start, meta = read_metadata(input, start)
    metadata.concat meta
  end

  # now read the metadata
  meta = input[start...(start + num_metadata)]
  metadata.concat meta

  debug "  read metadata #{meta}"
  [start + num_metadata, metadata]
end

class Node
  attr_reader :children, :metadata

  def self.read_tree(input, i = 0)
    num_children = input[i]
    num_metadata = input[i + 1]

    # recurse: read children and their metadata
    start = i + 2
    children = []
    num_children.times do
      start, child = read_tree(input, start)
      children << child
    end

    # now read the metadata
    metadata = input[start...(start + num_metadata)]
    [start + num_metadata, new(children, metadata)]
  end

  def initialize(children, metadata)
    @children = children
    @metadata = metadata
  end

  def to_s(indent: 0)
    space = " " * indent * 2
    "#{space}node with #{children.length} children and metadata #{metadata}\n" +
      children.map { |child| child.to_s(indent: indent + 1) }.join
  end
end

def node_value(node)
  debug "calculating node value of #{node}"

  if node.children.empty?
    debug "  node is empty, value is #{node.metadata.sum}"
    node.metadata.sum
  else
    values = node.metadata.map do |i|
      debug "  fetching value of child #{i} (#{node.children.length})"
      next 0 if i.zero?

      i -= 1 # 0-index into children
      if i < node.children.length
        node_value(node.children[i])
      else
        0
      end
    end

    debug "  values from metadata: #{values}"
    values.sum
  end
end

ex1 = <<-EX
2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2
EX

part 1
with :part1
debug!
try ex1, expect: 138
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, expect: 66
no_debug!
try puzzle_input
