dofile_once("mods/gb_util/files/dump.lua")
dofile_once("mods/backpack_gb/files/backpack.lua")

function OnPlayerSpawned(player) -- This runs when player entity has been created
	--print("-------------- BEFORE -------------------")
	--dump_e(player)
	--local inv = EntityGetFirstComponentIncludingDisabled(player, "Inventory2Component")
	--local i_quick = nil
	--local i_full = nil
	local wand
	local item
	local card
	local children = EntityGetAllChildren(player)
	if (children ~= nil) then
		for _, child in pairs(children) do
			local name = EntityGetName(child)
			if (name == "backpack_wand") then wand = child end
			if (name == "backpack_item") then item = child end
			if (name == "backpack_card") then card = child end
		end
	end

	if not wand then wand = init_backpack(player, "wand") end
	if not item then item = init_backpack(player, "item") end
	if not card then card = init_backpack(player, "card") end

	ComponentSetValue2(EntityGetFirstComponent(player, "Inventory2Component"), "full_inventory_slots_y", 3) -- MOAR SPELLS!

	-- only do this once!!!
	-- probably safter to just check it but naah
	---if tonumber(StatsGetValue("playtime")) > 1 then return end

	--print("\n\n\n-------------- AFTER -------------------")
	--dump_e(player, 2)
	--print(str(_G, 1, true)) -- how polluted do we get?
end
