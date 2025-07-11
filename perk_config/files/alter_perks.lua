local _pc_get_setting = function (prefix, perk)
	--print('TELL', tostring(perk))
	return ModSettingGet("perk_config." .. prefix .. perk.id)
end

for _, perk in pairs(perk_list) do
	local warn = ModSettingGet( "perk_config.warn_unrecognized");
	local enabled = _pc_get_setting( "PC_ENABLED_", perk)

	if enabled == nil then
		if warn then
			GamePrint( "PERK CONFIG: IGNORING " .. perk.id )
		end
	elseif enabled == true then

		local max_stack = _pc_get_setting('PC_STACK_', perk)
		local pool = _pc_get_setting('PC_POOL_', perk)

		if max_stack == 0 then
			perk.stackable_maximum = nil
		else
			perk.stackable_maximum = max_stack
		end

		if pool == 0 then
			perk.max_in_perk_pool = nil
		else
			perk.max_in_perk_pool = pool
		end

	elseif enabled == false then
		perk.not_in_default_perk_pool = true -- cya bitch
	else
		print("what is this value... boo");
	end

end
