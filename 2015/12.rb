require_relative "../toolkit"
require "json"

def number_sum(input, &value_filter)
  input.scan(/-?\d+/).map(&:to_i).sum
end

part 1
with :number_sum
try '[1,2,3]', 6
try '{"a":2,"b":4}', 6
try '[[[3]]]', 3
try '{"a":{"b":4},"c":-1}', 3
try '{"a":[-1,1]}', 0
try '[-1,{"a":1}]', 0
try '[]', 0
try '{}', 0
try puzzle_input

def number_sum(input, &value_filter)
  json = JSON.parse(input)
  numbers = Enumerator.new { |enum| scan json, value_filter, enum }
  numbers.sum
end

def scan(json, value_filter, enum)
  case json
  when Array
    json.each { |entry| scan entry, value_filter, enum }
  when Hash
    if value_filter && json.values.any?(&value_filter)
      return
    end
    json.values.each { |entry| scan entry, value_filter, enum }
  when Integer
    enum << json
  end
end

with(:number_sum) { |value| value == "red" }
try '[1,2,3]', 6
try '[1,{"c":"red","b":2},3]', 4
try '{"d":"red","e":[1,2,3,4],"f":5}', 0
try '[1,"red",5]', 6
try puzzle_input
