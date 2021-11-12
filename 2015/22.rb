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

  def done?
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
  Spell.new("Recharge", cost: 229, effect: Effect.new("Poison", duration: 5, mana_regen: 101)),
]

def part1(input, player_hp: 50, player_mana: 500)
  bhp, boss_damage = *get_boss(input)

  resolve_turns = lambda do |hp, mana, boss_hp, effects = [], spells = []|
    indent = "->" * spells.length
    efs = "[#{effects.map { |e| "#{e.name} (#{e.duration})" }.join(", ")}]"
    debug "#{indent}player turn: #{hp} hp #{mana} mana, boss #{boss_hp} hp, effects: #{efs}, spells: [#{spells.map(&:name).join(", ")}]"

    # figure out what spell to cast
    SPELLS.each do |spell|
      next if effects.map(&:name).include?(spell.effect&.name)
      next unless spell.cost <= mana

      debug "#{indent}  casting #{spell.name}"

      # see what happens if we cast this spell:
      next_hp = hp
      next_mana = mana - spell.cost
      next_boss_hp = boss_hp
      next_effects = effects + (spell.effect ? [spell.effect] : [])

      # resolve effects
      regen = next_effects.map(&:mana_regen).sum
      if regen.positive?
        next_mana += regen
        debug "#{indent}    mana regens #{regen}, now #{next_mana}"
      end

      effect_damage = next_effects.map(&:damage).sum
      if effect_damage.positive?
        next_boss_hp -= effect_damage
        debug "#{indent}    effects damage #{effect_damage}, boss hp now #{next_boss_hp}"
        if next_boss_hp < 0
          debug "#{indent}  boss dead"
          return spells
        end
      end

      if spell.heal.positive?
        debug "#{indent}    spell heals #{spell.heal}"
        next_hp = hp + spell.heal
      end

      if spell.damage.positive?
        next_boss_hp -= spell.damage
        debug "#{indent}  player spell attacks for #{spell.damage}, boss now #{next_boss_hp}"
        if next_boss_hp < 0
          debug "#{indent}  boss dead"
          return spells
        end
      end

      # ---- boss turn -----
      debug "#{indent}boss turn: #{next_hp} hp #{next_mana} mana, boss #{next_boss_hp} hp"

      # iterate effects
      next_effects = next_effects.map(&:next).reject(&:done?)

      regen = next_effects.map(&:mana_regen).sum
      if regen.positive?
        next_mana += regen
        debug "#{indent}    mana regens #{regen}, now #{next_mana}"
      end

      effect_damage = next_effects.map(&:damage).sum
      if effect_damage.positive?
        next_boss_hp -= effect_damage
        debug "#{indent}    effects damage #{effect_damage}, boss hp now #{next_boss_hp}"
        if next_boss_hp < 0
          debug "#{indent}  boss dead"
          return spells
        end
      end

      # boss attacks
      armor = next_effects.map(&:armor).sum
      damage = [boss_damage - armor, 1].max
      next_hp -= damage
      debug "#{indent}  boss attacks for #{damage}: player now #{next_hp}"
      if next_hp <= 0
        debug "#{indent}  player died"
        return nil
      end

      # iterate effects before resolving the next turn
      next_effects = next_effects.map(&:next).reject(&:done?)

      if (next_best = resolve_turns.call next_hp, next_mana, next_boss_hp, next_effects, spells + [spell])
        return next_best
      end
    end

    debug "#{indent}  player could not cast any spells, and loses."
    nil
  end

  spells = resolve_turns.call player_hp, player_mana, bhp
  puts "spells: #{spells.map(&:name).join(", ")}"
  spells.map(&:cost).sum
end

ex1 = <<EX
Hit Points: 13
Damage: 8
EX

part 1
with :part1, player_hp: 10, player_mana: 250
debug!
try ex1, expect: 226 # poison then magic missile
# no_debug!
with :part1
try puzzle_input

# part 2
# with :part2
# try ex1, expect: nil
# try puzzle_input
