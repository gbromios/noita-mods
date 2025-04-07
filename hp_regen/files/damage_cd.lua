dofile_once('mods/hp_regen/files/storage.lua')
-- i reset the damange cooldown hehehe
function damage_received(damage, desc, entity_who_caused, is_fatal)
  ---print('HIS OUCHIE HAS OCCURED')
  local player = GetUpdatedEntityID()
  local regen = get_regen_entity(player)
  if not regen then return end

  local m = load_hp_regen_damage_cd(regen)

  if m == 0 then return end -- not my problem tbh
  -- this is when u can start healing again... ok
  local f_ok = GameGetFrameNum() + m
  ---print('.....CAN HEAL AFTER FRAME: ', f_ok)
  save_hp_regen_damage_ok (regen, f_ok)
end
