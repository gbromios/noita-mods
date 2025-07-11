dofile_once( "data/scripts/perks/perk.lua" )
function OnPlayerSpawned( player )
	if tonumber(StatsGetValue("playtime")) > 1 then
		return
	end
	
	local get_setting = function (prefix, perk)
		return ModSettingGet("perk_config." .. prefix .. perk.id)
	end

	for _, perk in pairs(perk_list) do
		local enabled = get_setting( "PC_ENABLED_", perk)
		local start_with = get_setting('PC_START_', perk)

		if enabled and start_with ~= nil then
			local i = 0
			while i < start_with do
				i = i + 1
				--GamePrint( "GIB: " .. perk.id .. " TO " .. tostring(player) )
				perk_pickup( 0, player, perk.id, false, false, true )
			end
		end

	end
end

ModLuaFileAppend( "data/scripts/perks/perk_list.lua", "mods/perk_config/files/alter_perks.lua" ) -- Basically dofile("mods/example/files/actions.lua") will appear at the end of gun_actions.lua

--print("Example mod init done")
