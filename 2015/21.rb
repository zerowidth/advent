require_relative "../toolkit"

shop = <<SHOP
Weapons:    Cost  Damage  Armor
Dagger        8     4       0
Shortsword   10     5       0
Warhammer    25     6       0
Longsword    40     7       0
Greataxe     74     8       0

Armor:      Cost  Damage  Armor
Leather      13     0       1
Chainmail    31     0       2
Splintmail   53     0       3
Bandedmail   75     0       4
Platemail   102     0       5

Rings:      Cost  Damage  Armor
Damage +1    25     1       0
Damage +2    50     2       0
Damage +3   100     3       0
Defense +1   20     0       1
Defense +2   40     0       2
Defense +3   80     0       3
SHOP

class Item
  attr_reader :name, :cost, :damage, :armor

  def initialize(name, cost, damage, armor)
    @name = name
    @cost = cost
    @damage = damage
    @armor = armor
  end

  def to_s
    "#{name}: cost #{cost} damage #{damage} armor #{armor}"
  end

  def inspect
    "<#{self}>"
  end
end

class Player
  def self.parse(input)
    matched = %r(Hit Points: (\d+)\nDamage: (\d+)\nArmor: (\d+))m.match(input)
    raise "couldn't match player" unless matched

    new($1.to_i, $2.to_i, $3.to_i)
  end

  attr_reader :hit_points, :damage, :armor

  def initialize(hit_points, damage = 0, armor = 0)
    @hit_points = hit_points
    @damage = damage
    @armor = armor
  end

  def wins_against?(other, items = [])
    attack_damage = [damage + items.map(&:damage).sum - other.armor, 1].max
    defend_damage = [other.damage - armor - items.map(&:armor).sum, 1].max
    attack_rounds = other.hit_points / attack_damage
    defend_rounds = hit_points / defend_damage
    debug "  attacking with    #{attack_damage}, wins  in #{attack_rounds} rounds"
    debug "  defending against #{defend_damage}, loses in #{defend_rounds} rounds"
    attack_rounds <= defend_rounds
  end

  def to_s
    "hit points #{hit_points} damage #{damage} armor #{armor}"
  end

  def inspect
    "<#{self.class.name}: #{self}>"
  end
end

def parse_shop(input)
  shop = {}
  input.split("\n\n").each do |section|
    items = section.lines.drop(1).map do |line|
      parts = line.split(/\s{2,}/)
      name = parts[0]
      values = parts[1..].map(&:to_i)
      Item.new(name, values[0], values[1], values[2])
    end
    name = section.lines.first.split(":").first
    shop[name] = items
  end
  shop
end

def parse_player(input)
  raise "couldn't match player" unless %r(Hit Points: (\d+)\nDamage: (\d+)\nArmor: (\d+))m.match(input)
  Player.new($1.to_i, $2.to_i, $3.to_i)
end

SHOP = parse_shop(shop)

def winning_combos(player, boss)
  weapons = SHOP["Weapons"]
  armor = SHOP["Armor"]
  rings = SHOP["Rings"]
  # must take: one weapon, 0 to 1 armor, 0 to 2 rings
  armor_combos = armor.all_combinations(min_length: 0, max_length: 1).to_a
  ring_combos = rings.all_combinations(min_length: 0, max_length: 2).to_a

  debug "player: #{player.inspect}"
  debug "boss: #{boss.inspect}"

  weapons.product(armor_combos, ring_combos).map(&:flatten).map do |items|
    cost = items.map(&:cost).sum
    debug "#{items.map(&:inspect).join(", ")} cost #{cost}"
    wins = player.wins_against?(boss, items)
    debug "  wins: #{wins}"
    [items, cost, wins]
  end
end

def part1(input)
  player = Player.new(100)
  boss = Player.parse(input)
  debug "player: #{player.inspect}"
  debug "boss: #{boss.inspect}"

  winning = winning_combos(player, boss).select { |_items, _cost, wins| wins }
  cheapest = winning.sort_by { |_items, cost, _wins| cost }.first
  puts "cheapest: #{cheapest.inspect}"
  cheapest[1]
end

def part2(input)
  player = Player.new(100)
  boss = Player.parse(input)
  lost = winning_combos(player, boss).select { |_items, _cost, wins| !wins }
  costly = lost.sort_by { |_items, cost, _wins| cost }.last

  puts "most costly loss: #{costly.inspect}"
  costly[1]
end

ex1 = <<-EX
Hit Points: 12
Damage: 7
Armor: 2
EX

part 1
with :part1
debug!
try ex1, expect: 8
no_debug!
try puzzle_input

part 2
with :part2
# try ex1, expect: nil
try puzzle_input
