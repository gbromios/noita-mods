function init_backpack (player, name)
	print("BACKPACK: INIT " .. name)
    local pages = ModSettingGet('backpack_gb.backpack_pages')
    if not pages or pages <= 1 then
      print('OH.... NEVERMIND (backpack_pages='.. tostring(pages) .. ')')
      return
    end

		local backpack = EntityLoad("mods/backpack_gb/files/backpack_entity.xml")
		EntitySetName(backpack, "backpack_" .. name)
    local p = 2
    while p <= pages do
      --GamePrint('ADD PAGE ' .. p .. ' TO ' .. name)
      local new_page = EntityCreateNew(tostring(p));
      EntityAddChild(backpack, new_page)
      p = p + 1
    end

    local slot_count = EntityGetFirstComponent(backpack, "VariableStorageComponent", "slot_count")
	  ComponentSetValue2(slot_count, "value_int", pages)

		EntityAddChild(player, backpack)


		if name == "wand" then
			EntityLoadToEntity("mods/backpack_gb/files/backpack_gui.xml", player)
		end

		return backpack
end

function add_slot (bp)
	-- TODO add some fresh ents
end

function swap_slot (bp, inv, c, prev_slot, next_slot, move_wands)
	print("OK GO " .. tostring(prev_slot) .. " => " .. tostring(next_slot))

	local e_prev
	local e_next

	local nn = tostring(next_slot)
	local pn = tostring(prev_slot)

	for _, e in pairs(EntityGetAllChildren(bp)) do
		local en = EntityGetName(e)
		if en == pn then e_prev = e end
		if en == nn then e_next = e end
		if e_prev and e_next then break end
	end

	swap_inv(inv, e_prev, move_wands)
	ComponentSetValue2(c, "value_int", next_slot)
	swap_inv(e_next, inv, move_wands)
end

function swap_inv (from, to, move_wands)
	--[[
	print('\n----==== BEFORE=========================================================================\n----==============----')
	print('----==== FROM ====----')
	dump_e(from)
	print('----====  TO  ====----')
	dump_e(to)
	print('----==============----\n\n')
	]]--

	local children = EntityGetAllChildren(from)
	if (children ~= nil) then
		for _, e in pairs(children) do
			if EntityHasTag(e, "wand") == move_wands then
				EntityRemoveFromParent(e)
				EntityAddChild(to, e)
			end
		end
	end

	--[[
	print('\n----==== AFTER=========================================================================\n----==============----')
	print('----==== FROM ====----')
	dump_e(from)
	print('----====  TO  ====----')
	dump_e(to)
	print('----==============----\n\n')
	]]--


end
