require_relative "../toolkit"
require_relative "../graph_search"

# Returns [hit points, damage]
def get_boss(input)
  matched = input.match(/Hit Points: (\d+)\nDamage: (\d+)/m)
  raise "couldn't parse boss metadata" unless matched

  [$1.to_i, $2.to_i]
end

class Effect
  attr_reader :name, :duration, :armor, :damage, :mana_regen

  def initialize(name, duration:, armor: 0, damage: 0, mana_regen: 0)
    @name = name
    @duration = duration
    @armor = armor
    @damage = damage
    @mana_regen = mana_regen
  end

  def expiring?
    duration == 1
  end

  def expired?
    duration.zero?
  end

  def next
    self.class.new(name, duration: duration - 1, armor: armor, damage: damage, mana_regen: mana_regen)
  end
end

class Spell
  attr_reader :name, :cost, :damage, :armor, :heal, :effect

  def initialize(name, cost:, damage: 0, armor: 0, heal: 0, effect: nil)
    @name = name
    @cost = cost
    @damage = damage
    @armor = armor
    @heal = heal
    @effect = effect
  end
end

SPELLS = [
  Spell.new("Magic Missile", cost: 53, damage: 4),
  Spell.new("Drain", cost: 73, damage: 2, heal: 2),
  Spell.new("Shield", cost: 113, effect: Effect.new("Shield", duration: 6, armor: 7)),
  Spell.new("Poison", cost: 173, effect: Effect.new("Poison", duration: 6, damage: 3)),
  Spell.new("Recharge", cost: 229, effect: Effect.new("Recharge", duration: 5, mana_regen: 101)),
]

class State
  attr_reader :turn, :hp, :mana, :boss_hp, :effects, :spells

  def initialize(turn, hp, mana, boss_hp, effects = [], spells = [])
    @turn, @hp, @mana, @boss_hp, @effects, @spells = turn, hp, mana, boss_hp, effects, spells
  end

  def next_turn(next_hp, next_mana, next_boss_hp, spell: nil)
    next_effects = effects.map(&:next).reject(&:expired?)
    next_effects << spell.effect if spell&.effect
    next_spells = spell ? spells + [spell] : spells
    self.class.new(turn + 1, next_hp, next_mana, next_boss_hp, next_effects, next_spells)
  end

  def game_over?
    player_dead? || player_wins?
  end

  def player_dead?
    hp <= 0
  end

  def player_wins?
    hp > 0 && boss_hp <= 0
  end

  def resolve_turns(spell, boss_damage, hard_mode: false)
    next_state = resolve_player_turn(spell, hard_mode: hard_mode)
    debug "  #{next_state}"
    unless next_state.game_over?
      next_state = next_state.resolve_boss_turn(boss_damage)
      debug "  #{next_state}"
    end
    next_state
  end

  def resolve_player_turn(spell, hard_mode: false)
    debug "#{self} casting #{spell.name} for #{spell.cost} mana"

    next_hp = hp
    next_mana = mana - spell.cost
    next_boss_hp = boss_hp

    if hard_mode
      debug "  hard mode, player takes 1 damage"
      next_hp -= 1
      if next_hp <= 0
        debug "  hard player dies!"
        return next_turn(next_hp, next_mana, next_boss_hp, spell: spell)
      end
    end

    regen = effects.map(&:mana_regen).sum
    debug "  regen #{regen} mana" if regen > 0
    next_mana += regen
    damage = effects.map(&:damage).sum
    debug "  damage #{damage}" if damage > 0
    next_boss_hp -= damage

    if next_boss_hp <= 0
      debug "  boss dies!"
      return next_turn(next_hp, next_mana, next_boss_hp, spell: spell)
    end

    debug "  cast #{spell.name}"

    if spell.damage > 0
      debug "    damage #{spell.damage}"
      next_boss_hp -= spell.damage
    end

    if spell.heal > 0
      debug "    #{spell.name} heals #{spell.heal}"
      next_hp += spell.heal
    end

    debug "  boss dies!" if next_boss_hp <= 0

    next_turn(next_hp, next_mana, next_boss_hp, spell: spell)
  end

  def resolve_boss_turn(boss_damage)
    debug "#{self} boss attacking for #{boss_damage}"

    next_hp = hp
    next_mana = mana
    next_boss_hp = boss_hp

    regen = effects.map(&:mana_regen).sum
    debug "  regen #{regen} mana" if regen > 0
    next_mana += regen
    damage = effects.map(&:damage).sum
    debug "  damage #{damage}" if damage > 0
    next_boss_hp -= damage
    armor = effects.map(&:armor).sum
    debug "  armor #{armor}" if armor > 0

    if next_boss_hp <= 0
      debug "  boss dies!"
      return next_turn(next_hp, next_mana, next_boss_hp)
    end

    # attack player
    damage = [boss_damage - armor, 1].max
    debug "  boss attacks for #{damage}"
    next_hp -= damage
    debug "  player dies!" if next_hp <= 0

    next_turn(next_hp, next_mana, next_boss_hp)
  end

  def to_s
    efs = "[#{effects.map { |e| "#{e.name} (#{e.duration})" }.join(", ")}]"
    sps = "[#{spells.map(&:name).join(", ")}]"
    cost = spells.map(&:cost).sum
    "<#{cost} turn #{turn}: player #{hp} hp #{mana} mana; boss #{boss_hp} hp; effects #{efs}, spells #{sps}>"
  end

  def inspect
    to_s
  end
end

def least_mana(player_hp, player_mana, boss_hp, boss_damage, hard_mode: false)
  search = GraphSearch.new do |config|
    config.debug = $debug
    config.cost = lambda do |_from, to|
      to.spells.last.cost
    end
    config.break_if = lambda do |cost, best|
      cost > best
    end
    config.neighbors = lambda do |state|
      return [] if state.game_over?

      spells = SPELLS.select do |spell|
        spell.cost <= state.mana && !state.effects.reject(&:expiring?).map(&:name).include?(spell.name)
      end

      spells.map do |spell|
        state.resolve_turns(spell, boss_damage, hard_mode: hard_mode)
      end.reject(&:player_dead?)
    end
  end

  start = State.new(1, player_hp, player_mana, boss_hp)
  puts "searching from: #{start}"
  win = search.path(start: start) do |state|
    puts "*** player wins :#{state}" if state.player_wins?
    state.player_wins?
  end

  if win&.first&.any?
    puts "winning spells: #{win.first.last.spells.map(&:name)}"
    debug "-----"
    win.first.last.spells.reduce(start) do |state, spell|
      state.resolve_turns(spell, boss_damage, hard_mode: hard_mode)
    end
    debug "-----"
  end
  win&.last
end

def part1(input, player_hp:, player_mana:)
  boss_hp, boss_damage = *get_boss(input)
  least_mana(player_hp, player_mana, boss_hp, boss_damage)
end

def part2(input, player_hp:, player_mana:)
  boss_hp, boss_damage = *get_boss(input)
  least_mana(player_hp, player_mana, boss_hp, boss_damage, hard_mode: true)
end

ex1 = <<EX
Hit Points: 13
Damage: 8
EX

ex2 = <<EX
Hit Points: 14
Damage: 8
EX

part 1
with :part1, player_hp: 10, player_mana: 250
# debug!
try ex1, expect: 226 # Poison, Magic Missile
try ex2, expect: 641 # Recharge, Shield, Drain, Poison, Magic Missile
no_debug!
with :part1, player_hp: 50, player_mana: 500
try puzzle_input # 900

part 2
with :part2, player_hp: 10 + 2, player_mana: 250
no_debug!
# debug!
try ex1, expect: 226
with :part2, player_hp: 10 + 5, player_mana: 250
try ex2, expect: 641
no_debug!
with :part2, player_hp: 50, player_mana: 500
try puzzle_input # 1216
