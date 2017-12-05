# Advent of Code

Solutions for https://adventofcode.com.

## Template

```ruby
require_relative "../toolkit"

def solution(input)
  input.lines.map do |line|
    # ...
  end
end

example = <<-EX
EX

part 1
with(:solution)
try "input", 0
try example, 0
try puzzle_input

# part 2
# with(:solution)
# try "input", 0
# try example, 0
# try puzzle_input
```
