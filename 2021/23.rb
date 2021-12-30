require_relative "../toolkit"
require_relative "../graph_search"

PODS = %w[A B C D]

def cost_for(amphipod, distance)
  distance * (10 ** PODS.index(amphipod))
end

class State
  attr_reader :hallway, :rooms, :cost, :hallway_positions, :room_positions

  def initialize(hallway, rooms, cost, hallway_positions, room_positions)
    @hallway = hallway
    @rooms = rooms
    @cost = cost
    @hallway_positions = hallway_positions
    @room_positions = room_positions
  end

  def neighbors
    ns = []

    # for each amphipod in a hallway, can it move to its correct room?
    hallway.each_with_index do |pod, hx|
      next if pod.nil?

      # see if it can get to its room:
      room = PODS.index(pod)

      # room is free, either has its designated amphipods only or empty space
      next unless rooms[room].all? { |r| r.nil? || r == pod }

      # debug { "room #{room} available for #{pod}" } if pod == "C"

      # find the room depth we can get to next (deepest only)
      next unless (rd = rooms[room].rindex(&:nil?))

      # debug { "rd #{rd}" } if pod == "C"

      # now find out who's in our way and how far down the hallway we have to go
      rx = room_positions[room]
      if rx < hx
        unless rx.upto(hx - 1).all? { |i| hallway[i].nil? }
          # debug { "skipping, rx #{rx} to hx #{hx} is #{hallway[rx..hx]} #{hallway}".colorize(:red) }
          next
        end
      else
        unless (hx + 1).upto(rx).all? { |i| hallway[i].nil? }
          # debug { "skipping, hx #{hx} to rx #{rx} is #{hallway[rx..hx]} #{hallway}".colorize(:red) }
          next
        end
      end

      cost_delta = cost_for(pod, 1 + rd + (hx < rx ? rx - hx : hx - rx))
      new_hallway = hallway.dup
      new_rooms = rooms.map(&:dup)
      new_hallway[hx] = nil
      new_rooms[room][rd] = pod
      ns << State.new(new_hallway, new_rooms, cost + cost_delta, hallway_positions, room_positions)
    end

    # for each amphipod not in its room, get the list of hallway positions it can move to
    rooms.each_with_index do |room, ri|
      expect = PODS[ri]
      # an amphipod must move out of a room if:
      # - it's not in the right room
      # - it's blocking another amphipod that isn't in the right room
      next unless room.index { |p| p && p != expect }

      # first amphipod in the room must move
      rd = room.index { |p| !p.nil? }

      pod = room[rd]

      # find candidate hallway positions to move to
      rx = room_positions[ri]
      hallway_positions.each do |hx|
        if rx < hx
          next unless rx.upto(hx).all? { |i| hallway[i].nil? }
        else
          next unless rx.downto(hx).all? { |i| hallway[i].nil? }
        end

        # candidate hallway at hlx:
        move_cost = cost_for(pod, 1 + rd + (hx < rx ? rx - hx : hx - rx))
        new_hallway = hallway.dup
        new_rooms = rooms.map(&:dup)
        new_hallway[hx] = pod
        new_rooms[ri][rd] = nil
        ns << State.new(new_hallway, new_rooms, cost + move_cost, hallway_positions, room_positions)
      end
    end

    ns
  end

  def to_s
    hs = hallway.map.with_index do |h, i|
      if hallway_positions.include?(i)
        h || "."
      elsif room_positions.include?(i)
        "."
      else
        " "
      end
    end.compact.join
    lines = rooms.first.length.times.map do |row|
      line = " " * room_positions.max
      room_positions.each.with_index do |rp, i|
        line[rp] = rooms[i][row] || "."
      end
      line
    end
    "\n#{hs} (#{cost})\n#{lines.join("\n")}"
  end
end

def part1(input)
  rooms = input.lines[2, 2]
  # room x coords:
  rxs = rooms.first.indices(/[A-Z]/).to_a
  # hallway x coords:
  hlxs = input.lines[1].indices(".").to_a - rxs

  rooms = rooms.map { |r| r.scan(/[A-Z]/) }.transpose
  hallway = Array.new(hlxs.last, nil)

  start = State.new(hallway, rooms, 0, hlxs, rxs)
  finish = PODS.map { |p| [p] * rooms.first.length }

  search = GraphSearch.new do |config|
    config.debug = debug?
    config.cost = ->(from, to) { to.cost - from.cost }
    config.heuristic = lambda do |neighbor, _goal|
       (4 - (neighbor.rooms & finish).size) * 1000
    end
    config.neighbors = ->(state) { state.neighbors }
    config.break_if = ->(cost, _best) { cost > 13000 }
    # config.each_step = lambda do |start, current, came_from, cost_so_far|
      # debug current.to_s
      # debug { "start: #{show start}" }
      # if current.hallway.index("C") == 6
      #   print ("-" * 80).colorize(:magenta)
      #   gets
      # end
    # end
  end

  path = search.path(start: start) do |state|
    state.rooms == finish
  end
  debug { "path:\n#{path && path.first.map(&:to_s).join("\n")}" }
  path&.last
end

def part2(input)
  input.lines
end

ex1 = <<EX
#############
#...........#
###B#C#B#D###
  #A#D#C#A#
  #########
EX

part 1
with :part1
debug!
try ex1, 12521
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, nil
no_debug!
try puzzle_input
