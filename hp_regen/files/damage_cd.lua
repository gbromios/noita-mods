-- i reset the damange cooldown hehehe
function damage_received(damage, desc, entity_who_caused, is_fatal)
  ---print('HIS OUCHIE HAS OCCURED')
  local player = GetUpdatedEntityID()

	local children = EntityGetAllChildren(player, 'hp_regen_e')
  if not children or (#children < 1) then
    -- no regen, fuck it
    return
  end

  local regen = children[1]
  local varCD = EntityGetFirstComponent(
    regen,
    "VariableStorageComponent",
    "damage_cd"
  )
  local m = ComponentGetValue2(varCD, "value_int") or 0

  if m == 0 then return end -- not my problem tbh
  -- this is when u can start healing again... ok
  local f_ok = GameGetFrameNum() + (m * 60)
  ---print('.....CAN HEAL AFTER FRAME: ', f_ok)
  local varOK = EntityGetFirstComponent(
    regen,
    "VariableStorageComponent",
    "damage_ok"
  )
  ComponentSetValue2(varOK, "value_int", f_ok)
end
