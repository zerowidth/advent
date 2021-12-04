require_relative "../toolkit"

def spinlock(steps, rounds)
  steps = steps.to_i
  buf = [0]
  pos = 0
  rounds.times_with_progress do |n|
    pos = (pos + steps) % buf.length
    buf.insert pos + 1, n + 1
    pos = pos + 1
    # puts buf.inspect
  end
  if block_given?
    yield buf
  else
    buf[pos + 1]
  end
end

def after_zero(steps, rounds)
  steps = steps.to_i
  len = 1
  pos = 0
  after = nil
  rounds.times_with_progress do |n|
    pos = (pos + steps) % len
    if pos == 0
      after = n + 1
    end
    len += 1
    pos += 1
  end
  after
end

part 1
with(:spinlock, 9)
try 3, 5
with(:spinlock, 2017)
try 3, 638
try puzzle_input

part 2
with(:after_zero, 9) { |buf| i = buf.index(0); buf[i+1] }
try 3, 9
with(:after_zero, 50_000_000) { |buf| i = buf.index(0); buf[i+1] }
try puzzle_input
