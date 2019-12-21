require_relative "../toolkit"

def sum(input)
  input.split.map(&:to_i).sum
end

ex1 = <<EX
+1
+1
+1
EX

ex2 = <<EX
+1
+1
-2
EX

ex3 = <<EX
-1
-2
-3
EX

part 1
with(:sum)
try ex1, 3
try ex2, 0
try ex3, -6
try puzzle_input

# -----

ex1 = <<EX
+1
-1
EX

ex2 = <<EX
+3
+3
+4
-2
-4
EX

ex3 = <<EX
-6
+3
+8
+5
-6
EX

ex4 = <<EX
+7
+7
-2
-7
-4
EX

def repeat(input)
  list = input.split.map(&:to_i)
  seen = Set.new
  freq = 0

  list.cycle do |i|
    break freq if seen.include?(freq)
    seen << freq
    freq += i
  end
end


part 2

with(:repeat)

try ex1, 0
try ex2, 10
try ex3, 5
try ex4, 14
try puzzle_input


# part 2
# with(:solution)
# try example, 0
# try puzzle_input

