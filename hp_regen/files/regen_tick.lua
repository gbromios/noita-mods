dofile_once('mods/hp_regen/files/storage.lua')
--print('HEAL ME????')
local regen = GetUpdatedEntityID()
local player = EntityGetParent(regen)

local v = load_hp_regen_values(regen)

if not (v.enable_heal or v.enable_crit) then
  -- we should have caught this condition and stopped the script!
  print('uhh... no healing is enabled?')
  goto DONE
end

local damage = EntityGetFirstComponent(player, 'DamageModelComponent')

if not damage then
	print('no damage models')
	goto DONE
end

local hp = ComponentGetValue2(damage, 'hp')
local max_hp = ComponentGetValue2(damage, 'max_hp')

if hp >= max_hp then
  --print('no healing needed, 100% hp B-D')
  goto DONE
end

local f = GameGetFrameNum()

-- cooldown in effect
if v.damage_ok and f < v.damage_ok then
  print('damage cooldown in effect, frames = ', tostring((v.damage_ok or 0) - f))
  goto DONE
end

local heal = v.heal_flat + (v.heal_percent * max_hp)

if not (v.enable_crit and hp/max_hp < v.crit_threshold) then goto HEAL end
-- apply critical additions
--print(' - DO CRIT!')
if v.crit_mod > 0 then heal = heal * v.crit_mod end
heal = heal + v.crit_flat + (v.crit_percent * max_hp)

::HEAL::

local new_hp = hp + heal
local pct_healed = math.min(1, math.max(0, (heal / max_hp)))
if (new_hp > max_hp) then new_hp = max_hp end
ComponentSetValue(damage, 'hp', new_hp)

-- some particles ought to help show what happened
local pc = 10 + math.floor(pct_healed * 40)
local px, py = EntityGetTransform(player)
-- can we spartkle?
print(' - SPARKLE AT ', px, py)
GameCreateCosmeticParticle(
  'spark_green', -- material name
  px, -- x position
  py, -- y position
  pc,  -- how_many
  50, -- vx?
  50, -- vy?
  0xa099ffaa, --0, -- 0xa079ff89, -- 1, -- color:uint32 = 0, (WAT) NO COMMA HERE BUDDY
  16.0, -- lifetime_min:number = 5.0,
  20.0, -- lifetime_max:number = 10,
  true, -- force_create:bool = true,
  true, -- draw_front:bool = false,
  true, -- collide_with_grid:bool = true,
  true, -- randomize_velocity:bool = true,
  0, -- gravity_x = 0,
  80 -- gravity_y = 100,
)

print(' - VALUES USED:')
print('   - heal_flat:      ' .. tostring(v.heal_flat))
print('   - heal_pct :      ' .. tostring(v.heal_percent))
print('   - heal_pct * hp:  ' .. tostring(v.heal_percent * max_hp))
print('   - crit_threshold: ' .. tostring(v.crit_threshold))
print('   - crit_mod:       ' .. tostring(v.crit_mod))
print('   - crit_flat:      ' .. tostring(v.crit_flat))
print('   - crit_pct:       ' .. tostring(v.crit_percent))
print('   - crit_pct * hp   ' .. tostring(v.crit_percent * max_hp))
print('   - hp:             ' .. tostring(hp))
print('   - max_hp:         ' .. tostring(max_hp))
print('   - heal:           ' .. tostring(heal))
print('   - pct_healed      ' .. tostring(pct_healed))
print('   - pc:             ' .. tostring(pc))
print('   - hp%:            ' .. tostring(hp / max_hp))
print(' - - - - - - - - - - - - - - - - - -')

goto DONE
::DONE::
