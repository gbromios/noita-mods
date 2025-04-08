dofile_once('mods/hp_regen/files/storage.lua')
--dofile_once('mods/gb_util/files/dump.lua')

function load_settings_values ()
  local values = {
    enable_heal = ModSettingGet('hp_regen.enable_heal'),
    enable_crit =  ModSettingGet('hp_regen.enable_crit'),
    enable_damage_cd = ModSettingGet('hp_regen.enable_damage_cd'),
    heal_tick_f = -1,
    heal_tick_s = 1,
    heal_flat = 0,
    heal_percent = 0,
    crit_threshold = 0,
    crit_flat = 0,
    crit_percent = 0,
    crit_mod = 1,
    damage_cd = 0,
    damage_ok = 0
  }

  if values.enable_heal then
    -- ENABLE HEALS
    print('um heals enabled??????????????????????????????????????????')
    values.enable_tick = true
    values.heal_tick_s = ModSettingGet('hp_regen.heal_tick_s') or 1
    values.heal_flat = ModSettingGet('hp_regen.heal_flat') or 0
    values.heal_percent = ModSettingGet('hp_regen.heal_percent') or 0
  end
  if values.enable_crit then
    -- ENABLE CRITICAL HEALS
    values.enable_tick = true
    values.crit_flat = ModSettingGet('hp_regen.crit_flat') or 0
    values.crit_percent = ModSettingGet('hp_regen.crit_percent') or 0
    values.crit_threshold = ModSettingGet('hp_regen.crit_threshold') or 0.1
    if values.enable_heal then
      local crit_mod = ModSettingGet('hp_regen.crit_mod') or 0
      if crid_mod == 0 then values.crit_mod = 1
      else values.crit_mod = crit_mod
      end
    end
  end


  if values.enable_tick then
    -- make sure the damage thing is up to date and stuff
    values.heal_tick_f = values.heal_tick_s * 60
    if values.enable_damage_cd then
      local damage_cd = ModSettingGet('hp_regen.damage_cd') or 0
      values.damage_cd = damage_cd * 60
    end
  else
    values.heal_tick_f = -1
    values.damage_cd = 0
  end

  return values
end

function apply_regen_settings (player)
  --print('PLAYER GETS REGEN SETTINGS', player)
  -- check for regen entity
  -- if missing add it (and the damage-cd LuaComponent, hopefully they stay in sync? --
  local regen, script = init_regen_entity(player)
  if not regen or not script then
    --print('NO REGEN ENTITY!!!!!!')
    return
  end
  -- idk if we actually need to do anything once its initialized but whatever
  -- just make sure it exists
  init_damage_cd(player)

  local values = load_settings_values()
  save_hp_regen_values(values, regen, script)

  -- (needs gb_util)
  --print('VALUES HAVE BEEN SET, THANK YOU!!!!!')
  --print(str(values, true, 2, true))
  --] ]--

end

function init_regen_entity (player)
  local regen = get_regen_entity(player, true)
  if not regen then
    -- bummer!!!!
    return nil, nil
  end

  return regen, EntityGetFirstComponentIncludingDisabled(regen, 'LuaComponent')

  --if not script then
    -- TODO - how to not spam this message if it happens...
    --print('regen entity is missing the regen_tick.lua script!')
  --end

	--return regen, script
end

function init_damage_cd (player)
  local components = EntityGetComponent(player, 'LuaComponent')
	if components == nil then
		--print('HP_REGEN: PLAYER HAS NO CHILDREN?>????')
		return nil
	end
  if (#components) > 0 then
    for _, comp in pairs(components) do
      -- as long as we got one, we're good
      if ComponentGetValue2(comp, 'script_damage_received') == DAMAGE_CD_SRC then
        print('re-use the damage component')
        return
      end
    end
  end
  -- we did not get one, so create one
  EntityAddComponent2(player, 'LuaComponent', {
    execute_every_n_frame = -1,
    script_damage_received = DAMAGE_CD_SRC
  })
end

function OnPlayerSpawned (player)
  apply_regen_settings(player)
end

function OnPausedChanged(is_paused, is_inventory_pause)
  if is_paused or is_iventory_pause then return end
  --print('ok maybe re-init?!?!?')

  local players = EntityGetWithTag('player_unit')
	if players and (#players > 0) then
		for i, player_id in ipairs(players) do apply_regen_settings(player_id) end
	end
end
