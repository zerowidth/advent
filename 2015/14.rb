require_relative "../toolkit"

Reindeer = Struct.new(:name, :speed, :fly, :rest) do
  def initialize(*args)
    super
    @d = 0
    @t = 0
  end

  def distance_at(t)
    cycle_time = fly + rest
    full_cycles = t / cycle_time
    remainder = [t % cycle_time, fly].min
    (full_cycles * fly + remainder) * speed
  end

  def integrate
    cycle_time = fly + rest
    @t += 1
    mod = @t % cycle_time
    if mod > 0 && mod <= fly
      @d += speed
    end
  end

  def d
    @d
  end
end

def get_deer(input)
  input.lines.map do |line|
    if line =~ /(\w+) can fly (\d+) km\/s for (\d+) seconds, but then must rest for (\d+) seconds\./
      Reindeer.new $1, $2.to_i, $3.to_i, $4.to_i
    else
      raise "what? #{line.inspect}"
    end
  end
end

def reindeer_distance(input, seconds)
  deer = get_deer(input)
  Hash[deer.map { |d| [d.name, d.distance_at(seconds)] }]
end

def reindeer_games(input, seconds)
  reindeer_distance(input, seconds).sort_by(&:last).last
end

def reindeer_scores(input, seconds)
  deer = get_deer input

  scores = Hash.new(0)
  seconds.times do |t|
    deer.each(&:integrate)
    max_dist = deer.max_by(&:d).d
    leaders = deer.select { |d| d.d == max_dist }
    leaders.map { |l| scores[l.name] += 1 }
    # puts "t #{t+1} : #{Hash[ deer.map { |d| [d.name, d.d] } ] } #{scores.inspect}"
  end
  scores
end

example = <<-EX
Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.
Dancer can fly 16 km/s for 11 seconds, but then must rest for 162 seconds.
EX

part 1
with :reindeer_distance, 1000
try example, { "Comet" => 1120, "Dancer" => 1056 }
try puzzle_input
with :reindeer_games, 2503
try example, ["Comet", 2660]
try puzzle_input

part 2
with :reindeer_scores, 1
try example, { "Dancer" => 1 }
with :reindeer_scores, 140
try example, { "Comet" => 1, "Dancer" => 139 }
with :reindeer_scores, 1000
try example, { "Dancer" => 689, "Comet" => 312 }
with :reindeer_scores, 2503
try(puzzle_input) { |s| s.max_by(&:last) }
