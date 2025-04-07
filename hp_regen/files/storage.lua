DAMAGE_CD_SRC = 'mods/hp_regen/files/damage_cd.lua'
REGEN_ENTITY_SRC = 'mods/hp_regen/files/regen_entity.xml'
HP_REGEN_STORAGE_TYPES = {
  damage_cd =      'value_int',
  damage_ok =      'value_int',
  enable_heal =    'value_bool',
  heal_flat =      'value_float',
  heal_percent =   'value_float',
  enable_crit =    'value_bool',
  crit_threshold = 'value_float',
  crit_mod =       'value_float',
  crit_flat =      'value_float',
  crit_percent =   'value_float',
}

function get_regen_entity (player, init)
	local children = EntityGetAllChildren(player)
	if children == nil then
		--print('HP_REGEN: PLAYER HAS NO CHILDREN?')
		return nil
	end

  if (#children > 0) then
    for _, child in pairs(children) do
      if EntityGetName(child) == 'hp_regen' then return child end
    end
  end

  if init then
    -- create one if we didnt find one
    local regen = EntityLoad(REGEN_ENTITY_SRC)
    EntityAddChild(player, regen);
    return regen
  else
    -- dont create one even if we didnt find one
    return nil
  end
end

function load_hp_regen_values (regen)
  local values = {
    damage_ok = 0,
    enable_heal = false,
    enable_crit =  false,
    heal_flat = 0,
    heal_percent = 0,
    crit_threshold = 0,
    crit_flat = 0,
    crit_percent = 0,
    crit_mod = 1,
  }
  local components = EntityGetComponent(regen, 'VariableStorageComponent')
  if components then
    for _,comp in ipairs(components) do
      local name = ComponentGetValue2(comp, 'name')
      local attr = HP_REGEN_STORAGE_TYPES[name]
      if attr then values[name] = ComponentGetValue2(comp, attr) end
    end
  end
  return values
end

function save_hp_regen_values (values, regen, script)
  local components = EntityGetComponent(regen, 'VariableStorageComponent')
  if components then
    for _,comp in ipairs(components) do
      local name = ComponentGetValue2(comp, 'name')
      local attr = HP_REGEN_STORAGE_TYPES[name]
      if attr then
        print(string.format('SAVE %s '%s' TO %s', name, tostring(values[name]), attr))
        ComponentSetValue2(comp, attr, values[name])
      end
    end
  end
  ComponentSetValue2(script, 'execute_every_n_frame', values.heal_tick_f or -1)
end

function load_hp_regen_damage_cd (regen)
  local components = EntityGetComponent(regen, 'VariableStorageComponent')
  if not components then return 0 end
  for _,comp in ipairs(components) do
    local name = ComponentGetValue2(comp, 'name')
    if name == 'damage_cd' then
      return ComponentGetValue2(comp, HP_REGEN_STORAGE_TYPES.damage_cd) or 0
    end
  end
  return 0
end

function save_hp_regen_damage_ok (regen, value)
  local components = EntityGetComponent(regen, 'VariableStorageComponent')
  if not components then return end
  for _,comp in ipairs(components) do
    local name = ComponentGetValue2(comp, 'name')
    if name == 'damage_ok' then
      ComponentSetValue2(comp, HP_REGEN_STORAGE_TYPES.damage_ok, value)
      return
    end
  end
end
