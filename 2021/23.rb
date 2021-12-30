require_relative "../toolkit"
require_relative "../graph_search"

PODS = %w[A B C D]

def cost_for(amphipod, distance)
  distance * (10**PODS.index(amphipod))
end

class State
  attr_reader :hallway, :rooms, :cost

  def initialize(hallway, rooms, cost, hlxs, rxs)
    @hallway = hallway
    @rooms = rooms
    @cost = cost
  end

  def move_from_room(room, depth, hallway_x)
    new_hall = hallway.dup 
    new_rooms = rooms.map(&:dup)
  end

  def move_from_hallway(hallway_x, room)
  end

  def to_s
    ""
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

  search = GraphSearch.new do |config|
    # config.debug = debug?
    config.cost = ->(from, to) { to.last - from.last }
    config.neighbors = lambda do |state|
      neighbors = []

      # for each amphipod in a hallway, can it move to its correct room?
      hallway.each_with_index do |pod, hx|
        next if pod.nil?

        # see if it can get to its room:
        room = PODS.index(pod)
        # room is free, either has its designated amphipods only or empty space
        next unless state[1][room].all? { |r| r.nil? || r == pod }

        # find the room depth we can get to next (max, not trying multiple options)
        next unless (rd = state[1][room].rindex(&:nil?))
        # now find out who's in our way and how far down the hallway we have to go
        rx = rxs[room]
        if rx < hx
          next unless (rx..hx).all? { |i| state[0][i].nil? }
        else
          next unless (hx..rx).all? { |i| state[0][i].nil? }
        end

        cost = cost_for(pod, 1 + rd + (hx < rx ? rx - hx : hx - rx))
        hallway = state[0].dup
        rooms = state[1].map(&:dup)
        hallway[hx] = nil
        rooms[room][rd] = pod
        neighbors << [hallway, rooms, state[2] + cost]
      end

      # for each amphipod not in its room, get the list of hallway positions it can move to
      state[1].each_with_index do |room, ri|
        expect = PODS[ri]
        # an amphipod must move out of a room if:
        # - it's not in the right room
        # - it's blocking another amphipod that isn't in the right room
        next unless room.index { |p| p && p != expect }

        # first amphipod in the room must move
        rd = room.index { |p| !p.nil? } 

        pod = room[rd]

        # find candidate hallway positions to move to
        rx = rxs[ri]
        hlxs.each do |hx|
          if rx < hx
            next unless rx.upto(hx).all? { |i| state[0][i].nil? }
          else
            next unless rx.downto(hx).all? { |i| state[0][i].nil? }
          end

          # candidate hallway at hlx:
          cost = cost_for(pod, 1 + rd + (hx < rx ? rx - hx : hx - rx))
          hallway = state[0].dup
          rooms = state[1].map(&:dup)
          hallway[hx] = pod
          rooms[ri][rd] = nil
          neighbors << [hallway, rooms, state[2] + cost]
        end
      end

      neighbors
    end
    # config.each_step = lambda do |start, current, came_from, cost_so_far|
    #   debug { "start: #{show start}" }
    # end
  end

  # track cost separately for easier cost calcs
  start = [hallway, rooms, 0]

  path = search.path(start: start) do |state|
    PODS.each.with_index { |p, i| state[1][i].all? { |r| r == p } }
  end
  path
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
try ex1, nil
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, nil
no_debug!
try puzzle_input
