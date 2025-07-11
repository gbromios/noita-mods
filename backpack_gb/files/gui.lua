if initialized == nil then
	dofile_once("data/scripts/lib/utilities.lua")
	dofile_once("mods/gb_util/files/dump.lua")
	dofile_once("mods/backpack_gb/files/backpack.lua")

	_player = nil
	_quick = nil
	_full = nil

	initialized = true
	print("PEE PEE:", tostring(_G))
	--[[
	local tsorted = function (t)
		-- first, make a table with all the names as keys AND a list of names.
		local k_to_v = {}
		local names = {}

		for name, v in pairs(t) do table.insert(names, name) end
		table.sort(names, function (a, b) return a < b end)

		-- THEN return an iterator
		local i = 0
		return function ()
			i = i+1
			return names[i], t[ names[i] ]
		end
	end

	for k, v in tsorted(_G) do print(" - " .. tostring(k) .. " = " .. tostring(v)) end
	]]--

	gui = GuiCreate();

  local pages = ModSettingGet('backpack_gb.backpack_pages')
  -- take care when dealing with THICC numbers
  local offset = 2;
  if pages >= 10 then offset = 0 end

	draw_one = function (bp, name, x1, x2, inv, im_id)
		local vscs = EntityGetComponent(bp, "VariableStorageComponent")
		local c_current_slot
		local current_slot
		local next_slot
		local prev_slot

		-- calculate slot numbers based on current settings
		for _, cid in pairs(vscs) do 
			local n = ComponentGetValue2(cid, "name")
			if n == "current_slot" then
				c_current_slot = cid
				current_slot = ComponentGetValue2(cid, "value_int")
				next_slot = current_slot + 1
				prev_slot = current_slot - 1
			elseif n == "slot_count" then
				max = ComponentGetValue2(cid, "value_int")
			end
		end

		-- ensure wrapping occurs
		if prev_slot == 0 then prev_slot = max end
		if next_slot > max then next_slot = 1 end

		GuiIdPush(gui, im_id)
		GuiOptionsAddForNextWidget(gui, GUI_OPTION.DrawActiveWidgetCursorOff)
		local go_back = GuiImageButton( gui, im_id, x1, 8, tostring(current_slot), "data/ui_gfx/keyboard_cursor_right.png")
		GuiIdPop(gui)

		GuiIdPush(gui, im_id + 1)
		GuiOptionsAddForNextWidget(gui, GUI_OPTION.DrawActiveWidgetCursorOff)
		local go_fwd = GuiImageButton( gui, im_id + 1, x2, 8, "", "data/ui_gfx/keyboard_cursor.png")
		GuiIdPop(gui)

		if go_back then
			print("<<< " .. name)
			swap_slot(bp, inv, c_current_slot, current_slot, prev_slot, name == 'backpack_wand')
			--dump_e(_player, 2)
		end
		if go_fwd then
			print(">>> " .. name)
			swap_slot(bp, inv, c_current_slot, current_slot, next_slot, name == 'backpack_wand')
			--dump_e(_player, 2)
		end
	end

	_update_player = function ()
		_player = GetUpdatedEntityID()
		_quick = nil
		_full = nil
		for _, e in pairs(EntityGetAllChildren(_player)) do
			local n = EntityGetName(e)
			if (n == "inventory_quick") then _quick = e end
			if (n == "inventory_full") then _full = e end
			if (_quick ~= nil and _full ~= nil) then break end
		end
	end


	draw = function () 
		if GameIsInventoryOpen() == false then return end

		_update_player()
		backpacks = EntityGetWithTag("backpack")
		GuiStartFrame( gui )

		for _, b in pairs(backpacks) do
			local name = EntityGetName(b)
			if name == 'backpack_wand' then
				draw_one(b, name, 1 + offset, 50, _quick, 1)
			elseif name == 'backpack_item' then
				draw_one(b, name, 82 + offset, 129, _quick, 3)
			elseif name == 'backpack_card' then
				draw_one(b, name, 170 + offset, 224, _full, 5)
			end
		end
		--str(backpacks)
	end



end

draw()


