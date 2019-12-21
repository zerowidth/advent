# Advent of Code

Solutions for https://adventofcode.com.

## Template

```ruby
require_relative "../toolkit"

def solution(input)
  result = input.lines.map do |line|
    # ...
  end

  block_given? ? yield(result) : result
end

example = <<-EX
EX

part 1
with(:solution)
try example, 0
try puzzle_input

# part 2
# with(:solution)
# try example, 0
# try puzzle_input
```
