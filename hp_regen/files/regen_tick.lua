--print('HEAL ME????')
local regen = GetUpdatedEntityID()
local player = EntityGetParent(regen)
local getV = function (tag, attr)
  local comp = EntityGetFirstComponentIncludingDisabled(
    regen,
    'VariableStorageComponent',
    tag
  )
  if comp then
    return ComponentGetValue2(comp, attr)
  else
    print('FAILED TO GET COMPONENT "'.. tag ..'"')
    return nil
  end

end

local heal_enable = getV('heal_enable', 'value_bool')
local crit_enable = getV('crit_enable', 'value_bool')

if not (heal_enable or crit_enable) then
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
local cd = getV('damage_ok', 'value_int')

-- cooldown in effect
if not cd or f < cd then
  print('damage cooldown in effect, frames = ', tostring((cd or 0) - f))
  goto DONE
end

local heal_flat = getV('heal_flat', 'value_float')
local heal_pct = getV('heal_percent', 'value_float')
local crit_mod = getV('crit_mod', 'value_float')
local crit_threshold = getV('crit_threshold', 'value_float')
local crit_flat = getV('crit_flat', 'value_float')
local crit_pct = getV('crit_percent', 'value_float')

local heal = heal_flat + (heal_pct * max_hp)

if not (crit_enable and hp/max_hp < crit_threshold) then goto HEAL end
-- apply critical additions
print(' - DO CRIT!')
if crit_mod > 0 then heal = heal * crit_mod end
heal = heal + crit_flat + (crit_pct * max_hp)

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
print('   - heal_flat:      ' .. tostring(heal_flat))
print('   - heal_pct :      ' .. tostring(heal_pct))
print('   - heal_pct * hp:  ' .. tostring(heal_pct * max_hp))
print('   - crit_threshold: ' .. tostring(crit_threshold))
print('   - crit_mod:       ' .. tostring(crit_mod))
print('   - crit_flat:      ' .. tostring(crit_flat))
print('   - crit_pct:       ' .. tostring(crit_pct))
print('   - crit_pct * hp   ' .. tostring(crit_pct * max_hp))
print('   - hp:             ' .. tostring(hp))
print('   - max_hp:         ' .. tostring(max_hp))
print('   - heal:           ' .. tostring(heal))
print('   - pct_healed      ' .. tostring(pct_healed))
print('   - pc:             ' .. tostring(pc))
print('   - hp%:            ' .. tostring(hp / max_hp))
print(' - - - - - - - - - - - - - - - - - -')

goto DONE
::DONE::
