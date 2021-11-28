require_relative "../toolkit"

def part1(input)
  sleep_times = Hash.of_array
  guard = nil
  slept = nil
  input.lines.sort.each do |line|
    minute, action = *line.scan(/:(\d+)\] (.*)/).first
    minute = minute.to_i
    case action
    when /Guard #(\d+) begins/
      guard = $1.to_i
      debug "current guard now #{guard}"
    when "falls asleep"
      debug "guard #{guard} asleep #{minute}"
      slept = minute
    when "wakes up"
      debug "guard #{guard} awake #{minute}"
      sleep_times[guard].concat (slept...minute).to_a
    else
      raise "wtf: #{action.inspect}"
    end
  end

  debug "sleep_times #{sleep_times}"


  # Strategy 1: Find the guard that has the most minutes asleep. What minute
  # does that guard spend asleep the most?
  sleepiest = sleep_times.max_by { |guard, times| times.length }
  guard = sleepiest[0]
  minute = sleepiest[1].tally.max_by(&:last).first
  debug "guard #{guard} was sleepiest on minute #{minute}"
  guard * minute
end

ex1 = <<-EX
[1518-11-01 00:00] Guard #10 begins shift
[1518-11-01 00:05] falls asleep
[1518-11-01 00:25] wakes up
[1518-11-01 00:30] falls asleep
[1518-11-01 00:55] wakes up
[1518-11-01 23:58] Guard #99 begins shift
[1518-11-02 00:40] falls asleep
[1518-11-02 00:50] wakes up
[1518-11-03 00:05] Guard #10 begins shift
[1518-11-03 00:24] falls asleep
[1518-11-03 00:29] wakes up
[1518-11-04 00:02] Guard #99 begins shift
[1518-11-04 00:36] falls asleep
[1518-11-04 00:46] wakes up
[1518-11-05 00:03] Guard #99 begins shift
[1518-11-05 00:45] falls asleep
[1518-11-05 00:55] wakes up
EX

part 1
with :part1
debug!
try ex1, expect: 240
no_debug!
try puzzle_input

# part 2
# with :part2
# debug!
# try ex1, expect: nil
# no_debug!
# try puzzle_input
