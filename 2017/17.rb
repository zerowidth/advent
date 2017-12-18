require_relative "../toolkit"

def spinlock(steps, rounds)
  buf = [0]
  pos = 0
  1.upto(rounds) do |n|
    pos = (pos + steps) % buf.length
    buf.insert pos + 1, n
    pos = pos + 1
    # puts buf.inspect
    print "\r#{n} " if n % 100 == 0
  end
  if block_given?
    yield buf
  else
    buf[pos + 1]
  end
end

def after_zero(steps, rounds)
  len = 1
  pos = 0
  after = nil
  1.upto(rounds) do |n|
    pos = (pos + steps) % len
    if pos == 0
      after = n
    end
    len += 1
    pos += 1
    print "\r#{n} " if n % 10_000 == 0
  end
  after
end


part 1
with(:spinlock, 9)
try 3, 5
with(:spinlock, 2017)
try 3, 638
try puzzle_input.to_i

part 2
with(:after_zero, 9) { |buf| i = buf.index(0); buf[i+1] }
try 3, 9
with(:after_zero, 50_000_000) { |buf| i = buf.index(0); buf[i+1] }
try puzzle_input.to_i
