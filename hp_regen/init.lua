function apply_regen_settings (player)
  --print('PLAYER GETS REGEN SETTINGS', player)
  -- check for regen entity
  -- if missing add it (and the damage-cd LuaComponent, hopefully they stay in sync? --
  local regen = get_regen_entity(player)
  if not regen then
    --print('NO REGEN ENTITY!!!!!!')
    return
  end
  -- idk if we actually need to do anything once its initialized but whatever
  -- just make sure it exists
  init_damage_cd(player)

  local heal_enable = ModSettingGet('hp_regen.enable_heal')
  local crit_enable =  ModSettingGet('hp_regen.enable_crit')
  local damage_cd_enable = ModSettingGet('hp_regen.enable_damage_cd')
  local do_tick = heal_enable or crit_enable

  local heal_tick_f = -1

  local heal_tick_s = 1
  local heal_flat = 0
  local heal_percent = 0
  if heal_enable then
    -- ENABLE HEALS
    heal_tick_s = ModSettingGet('hp_regen.heal_tick_s') or 5
    heal_flat = ModSettingGet('hp_regen.heal_flat') or 0
    heal_percent = ModSettingGet('hp_regen.heal_percent') or 0
  end

  local crit_threshold = 0.1 -- whatever the default is idr
  local crit_flat = 0
  local crit_percent = 0
  local crit_mod = 0
  if crit_enable then
    -- ENABLE CRITICAL HEALS
    crit_flat = ModSettingGet('hp_regen.crit_flat') or 0
    crit_percent = ModSettingGet('hp_regen.crit_percent') or 0
    crit_threshold = ModSettingGet('hp_regen.crit_threshold') or 0
    if heal_enable then crit_mod = ModSettingGet('hp_regen.crit_mod') end
  end

  local damage_cd = 0
  if damage_cd_enable then
    -- ENABLE CRITICAL HEALS
    damage_cd = ModSettingGet('hp_regen.damage_cd')
  end

  setValueC(regen, 'heal_enable', 'value_bool', heal_enable)
  setValueC(regen, 'crit_enable', 'value_bool', crit_enable)

  if do_tick then
    -- make sure the damage thing is up to date and stuff
    heal_tick_f = heal_tick_s * 60
  else
    heal_tick_f = -1
    damage_cd = 0
  end

  local script = EntityGetFirstComponentIncludingDisabled(
    regen,
    'LuaComponent',
    'hp_regen_script'
  )

  if not script then
    --print('NO REGEN SCRIPT!?!?!?!?!')
    return
  end

  ComponentSetValue2(script, "execute_every_n_frame", heal_tick_f)
  setValueC(regen, 'damage_cd', 'value_int', damage_cd)

  -- if we are not ticking then then other settings just do not matter
  if not do_tick then return end

  -- now we can set the actual values used by the math
  setValueC(regen, 'heal_flat', 'value_float', heal_flat)
  setValueC(regen, 'heal_percent', 'value_float', heal_percent)
  setValueC(regen, 'crit_threshold', 'value_float', crit_threshold)
  setValueC(regen, 'crit_flat', 'value_float', crit_flat)
  setValueC(regen, 'crit_percent', 'value_float', crit_percent)
  -- idk how best to "disable" this thing
  if crit_mod == 0 then crit_mod = 1 end
  setValueC(regen, 'crit_mod', 'value_float', crit_mod)

  --[[ (needs gb_util)
  print('VALUES HAVE BEEN SET, THANK YOU!!!!!')
  print(str({
    heal_enable = heal_enable,
    crit_enable = crit_enable,
    heal_flat = heal_flat,
    heal_percent = heal_percent,
    crit_flat = crit_flat,
    crit_percent = crit_percent,
    crit_mod = crit_mod,
    crit_threshold = crit_threshold,
    damage_cd_enable = damage_cd_enable,
    damage_cd = damage_cd,
    heal_tick_s = heal_tick_s,
    heal_tick_f = heal_tick_f,
  }, true, 2, true))
  ]]--

end

function setValueC (regen, tag, attr, value)
  local comp = EntityGetFirstComponentIncludingDisabled(
    regen,
    'VariableStorageComponent',
    tag
  )
  if comp then
    ComponentSetValue2(comp, attr, value)
  else
    print('FAILED TO GET COMPONENT "'.. tag ..'"')
  end
end

function get_regen_entity (player)
	local children = EntityGetAllChildren(player, 'hp_regen_e')
	if children == nil then
		print("HP_REGEN: PLAYER HAS NO CHILDREN?")
		return nil
	end

  if (#children > 0) then return children[1] end
  print("HP_REGEN: CREATE REGEN ENTITY")
	local regen = EntityLoad("mods/hp_regen/files/regen_entity.xml")
  EntityAddTag(regen, 'hp_regen_e') 
	EntityAddChild(player, regen);
	return regen
end

function init_damage_cd (player)
  local damage_cd = EntityGetFirstComponent(player, "LuaComponent", "hp_regen_damage_cd")
  if damage_cd then return end
  EntityAddComponent2(player, "LuaComponent", {
    _tags="hp_regen_damage_cd",
    execute_every_n_frame = -1,
    script_damage_received = "mods/hp_regen/files/damage_cd.lua",
  })
end

function OnPlayerSpawned (player)
  apply_regen_settings(player)
end

function OnPausedChanged(is_paused, is_inventory_pause)
  if is_paused or is_iventory_pause then return end
  --print('ok maybe re-init?!?!?')

  local players = EntityGetWithTag( "player_unit" )
	if players and (#players > 0) then
		for i, player_id in ipairs(players) do apply_regen_settings(player_id) end
	end
end


