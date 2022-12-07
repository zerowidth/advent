require_relative "../toolkit"

class Node
  attr_reader :name, :children

  def initialize(name)
    @name = name
    @children = []
  end
end

class DirEntry < Node
  attr_reader :parent

  def initialize(name, parent)
    super name
    @parent = parent
  end

  def path
    p = [name]
    n = self
    p << n.name while (n = n.parent)
    p.reverse.join("/")
  end

  def dirs
    children.select { |c| c.is_a? DirEntry }
  end

  def size
    children.map(&:size).sum
  end
end

class FileEntry < Node
  attr_reader :size

  def initialize(name, size)
    super name
    @size = size
  end
end

def read_dirs(input)
  root = DirEntry.new("", nil)
  current = nil

  input.lines.each do |line|
    debug line
    case line
    when %r{^\$ cd /}
      current = root
      debug "pwd: #{current.path}"
    when /^\$ cd \.\./
      current = current.parent
      debug "pwd: #{current.path}"
    when /^\$ cd (.*)/
      current = current.children.find { |c| c.name == $1 }
      debug "pwd: #{current.path}"
    when /^\$ ls/
      # noop
    when /^dir (.*)/
      dir = DirEntry.new($1, current)
      current.children << dir
    when /^(\d+) (.*)/
      file = FileEntry.new($2, $1.to_i)
      current.children << file
    end
  end
  root
end

def part1(input)
  root = read_dirs(input)
  found = []
  stack = [root]
  while (dir = stack.pop)
    found << dir if dir.size < 100000
    stack.concat dir.dirs
  end
  found.map(&:size).sum
end

def part2(input)
  root = read_dirs(input)
  available_disk = 70000000
  min_unused = 30000000
  unused = available_disk - root.size
  to_free = min_unused - unused

  found = []
  stack = [root]
  while (dir = stack.pop)
    found << dir if dir.size > to_free
    stack.concat dir.dirs
  end

  found.map(&:size).min
end

ex1 = <<EX
$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k
EX

part 1
with :part1
debug!
try ex1, 95437
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, 24933642
no_debug!
try puzzle_input # not 34257857
