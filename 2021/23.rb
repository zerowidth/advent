require_relative "../toolkit"
require_relative "../graph_search"

PODS = %w[A B C D]

def cost_for(amphipod, distance)
  distance * (10 ** PODS.index(amphipod))
end

class AmphipodSearch
  attr_reader :distances
  attr_reader :intermediates

  # internal:
  attr_reader :hlen # hallway length
  attr_reader :rdepth # room depth

  # operates on single-array states:
  # [0..6 hallway, 7..14 rooms, 15 cost]
  #
  # hallway_coords: list of x coords for hallway positions
  # room_coords: x coords for rooms
  # rooms: array of arrays of starting amphipod positions
  #
  # pre-calculates costs and intermediate nodes for each hallway-to-room and
  # room-to-hallway transition, using lists of integer offsets into a state array
  def initialize(hallway_coords, room_coords, rooms)
    @distances = Hash.of_hash
    @intermediates = Hash.of_hash

    @rdepth = rooms.first.length
    @hlen = hallway_coords.length
    hallway_coords.each.with_index do |hx, hi|
      room_coords.each.with_index do |rx, ri|
        # intermediates between hallway and room:
        is = hx.to(rx).map { |x| x == hx ? nil : hallway_coords.index(x) }.compact
        rdepth.times do |r|
          i = hlen + (ri * rdepth) + r
          dist = (hx - rx).abs + 1 + r
          is << (i - 1) if r > 0 # mutating but it's ok
          distances[hi][i] = dist
          distances[i][hi] = dist
          intermediates[hi][i] = is.dup
          intermediates[i][hi] = is.dup
        end
      end
    end
  end

  def neighbors(state)
    ns = []

    # find hallway-to-room transitions:
    0.upto(hlen - 1) do |hi|
      next unless (pod = state[hi])

      # what room is this pod is supposed to go to?
      room = hlen + (PODS.index(pod) * rdepth)

      # does the room have only the right kind of amphipod in it?
      next unless state[room, rdepth].all? { |p| p.nil? || p == pod }

      # get the deepest empty space:
      ri = room + state[room, rdepth].rindex(nil)
      next unless clear?(state, hi, ri)

      new_state = state.dup
      new_state[hi] = nil
      new_state[ri] = pod
      new_state[-1] += cost(pod, distances[hi][ri])
      ns << new_state
    end

    # find room-to-hallway transitions:
    (rdepth * 4).times do |ri|
      room = ri / rdepth
      rd = ri % rdepth
      ri += hlen

      next unless (pod = state[ri])
      next if PODS.index(pod) == room && state[ri, rdepth - rd].all? { |p| p.nil? || p == pod }

      # find all available hallway locations to move to
      hlen.times do |hi|
        next unless state[hi].nil? && clear?(state, ri, hi)

        new_state = state.dup
        new_state[hi] = pod
        new_state[ri] = nil
        new_state[-1] += cost(pod, distances[ri][hi])
        ns << new_state
      end
    end

    ns
  end

  def clear?(state, from, to)
    intermediates[from][to].all? { |i| state[i].nil? }
  end

  def cost(amphipod, distance)
    distance * (10 ** PODS.index(amphipod))
  end

  def draw(state)
    hallway = state[0, hlen].map { |h| h || "." }
    rooms = state[hlen, rdepth * 4].each_slice(rdepth).map do |room|
      room.map { |r| r || "." }.join
    end
    "#{hallway} #{rooms.join(" ")} #{state.last}"
  end
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

def solve(hlxs, rxs, rooms)
  pods = AmphipodSearch.new(hlxs, rxs, rooms)
  start = ([nil] * pods.hlen) + rooms.flatten + [0]
  finish = PODS.flat_map { |p| [p] * rooms.first.length }
  debug { "start: #{start}" }
  debug { "finish: #{finish}" }

  search = GraphSearch.new do |config|
    config.debug = debug?
    config.cost = ->(from, to) { to.last - from.last }
    # config.heuristic = lambda do |neighbor, _goal|
    #    (4 - (neighbor.rooms & finish).size) * 1000
    # end
    config.neighbors = ->(state) { pods.neighbors(state) }
    # config.break_if = ->(cost, _best) { cost > 13000 }
    # config.each_step = lambda do |start, current, came_from, cost_so_far|
      # debug current.to_s
      # debug { "start: #{show start}" }
      # if current.hallway.index("C") == 6
      #   print ("-" * 80).colorize(:magenta)
        # gets
      # end
    # end
    # config.each_step = ->(*) { print "> "; gets }
  end

  path = search.path(start: start) do |state|
    state[pods.hlen, pods.rdepth * 4] == finish
  end
  debug { "path:\n#{path && path.first.map { |p| pods.draw(p) }.join("\n")}" }
  path
end

def part1(input)
  rooms = input.lines[2, 2]
  # room x coords:
  rxs = rooms.first.indices(/[A-Z]/).to_a
  # hallway x coords:
  hlxs = input.lines[1].indices(".").to_a - rxs
  # arrays of amphipods
  rooms = rooms.map { |r| r.scan(/[A-Z]/) }.transpose

  path = solve(hlxs, rxs, rooms)
  path&.last
end

part2_extra = <<EX
#D#C#B#A#
#D#B#A#C#
EX

def part2(input, extra)
  extra = Input.new(extra).lines
  rooms = input.lines[2, 2]
  rooms = [rooms[0]] + extra + [rooms[1]]
  # room x coords:
  rxs = rooms.first.indices(/[A-Z]/).to_a
  # hallway x coords:
  hlxs = input.lines[1].indices(".").to_a - rxs
  # arrays of amphipods
  rooms = rooms.map { |r| r.scan(/[A-Z]/) }.transpose

  path = solve(hlxs, rxs, rooms)
  path&.last
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
with :part2, part2_extra
debug!
try ex1, 44169
no_debug!
try puzzle_input
