require_relative "../toolkit"

class Sensor
  def initialize(sensor_x, sensor_y, beacon_x, beacon_y)
    @sx = sensor_x
    @sy = sensor_y
    @bx = beacon_x
    @by = beacon_y
  end

  def dist
    @dist ||= dx + dy
  end

  def dx
    @dx ||= (@bx - @sx).abs
  end

  def dy
    @dy ||= (@by - @sy).abs
  end

  def range(y)
    # debug "range at y=#{y} for [#{@sx}, #{@sy}]->[#{@bx}, #{@by}] (dx=#{dx}, dy=#{dy} = #{dx + dy})"
    distance_to_sensor = (y - @sy).abs
    # debug "  distance_to_sensor = #{distance_to_sensor}"
    return nil if distance_to_sensor > dist
    delta_x = dist - distance_to_sensor
    # debug "  delta_x = #{delta_x}"
    return nil if delta_x < 0
    min_x = @sx - delta_x
    max_x = @sx + delta_x
    (min_x..max_x) # .tap do |range|
    # debug "  range = #{range}"
    # end
  end
end

def part1(input, y:)
  positions = input.lines.map(&:signed_numbers)
  beacons = positions.map { |_, _, bx, by| [bx, by] }
  sensors = positions.map { |p| Sensor.new(*p) }
  ranges = sensors.map { |s| s.range(y) }.compact
  debug "ranges: #{ranges}"
  x_positions = ranges.flat_map(&:entries).uniq
  (x_positions - beacons.select { |_, by| by == y }.map(&:first)).count
end

def part2(input, x_max:, y_max:)
  positions = input.lines.map(&:signed_numbers)
  beacons = positions.map { |_, _, bx, by| [bx, by] }
  sensors = positions.map { |p| Sensor.new(*p) }
  coords = y_max.times_with_progress do |y|
    debug "searching y=#{y}"
    ranges = sensors.map { |s| s.range(y) }.compact.sort_by(&:min)
    debug "ranges: #{ranges}"
    found = nil
    x = 0
    while x <= x_max
      # debug "x is now #{x}"
      next_x = ranges.select { |r| r.include?(x) }.map(&:max).max
      # debug "next x #{next_x}"
      if next_x
        x = next_x + 1
      else
        found = x
        break
      end
    end
    break [found, y] if found
  end
  return unless coords
  coords[0] * 4_000_000 + coords[1]
end

ex1 = <<EX
Sensor at x=2, y=18: closest beacon is at x=-2, y=15
Sensor at x=9, y=16: closest beacon is at x=10, y=16
Sensor at x=13, y=2: closest beacon is at x=15, y=3
Sensor at x=12, y=14: closest beacon is at x=10, y=16
Sensor at x=10, y=20: closest beacon is at x=10, y=16
Sensor at x=14, y=17: closest beacon is at x=10, y=16
Sensor at x=8, y=7: closest beacon is at x=2, y=10
Sensor at x=2, y=0: closest beacon is at x=2, y=10
Sensor at x=0, y=11: closest beacon is at x=2, y=10
Sensor at x=20, y=14: closest beacon is at x=25, y=17
Sensor at x=17, y=20: closest beacon is at x=21, y=22
Sensor at x=16, y=7: closest beacon is at x=15, y=3
Sensor at x=14, y=3: closest beacon is at x=15, y=3
Sensor at x=20, y=1: closest beacon is at x=15, y=3
EX

part 1
with :part1, y: 10
debug!
try ex1, 26
no_debug!
with :part1, y: 2_000_000
try puzzle_input

part 2
with :part2, x_max: 20, y_max: 20
debug!
try ex1, 56000011
no_debug!
with :part2, x_max: 4000000, y_max: 4000000
try puzzle_input
