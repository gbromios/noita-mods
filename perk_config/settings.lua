dofile("data/scripts/lib/mod_settings.lua") -- see this file for documentation on some of the features.
dofile("data/scripts/perks/perk_list.lua")

-- local custom_perks = {} -- TODO (if necessary...?)


local mod_id = "perk_config" -- This should match the name of your mod's folder.
mod_settings_version = 1 -- This is a magic global that can be used to migrate settings to new mod versions. call mod_settings_get_version() before mod_settings_update() to get the old value. 


local vanilla_perk_settings = {}

function mod_setting_bool_custom( mod_id, gui, in_main_menu, im_id, setting )
	local value = ModSettingGetNextValue( mod_setting_get_id(mod_id,setting) )
	local text = setting.ui_name .. " - " .. GameTextGet( value and "$option_on" or "$option_off" )
	local x = mod_setting_group_x_offset
	if setting._x_margin ~= nil then
		x = x + setting._x_margin
	end
	if GuiButton( gui, im_id, x, 0, text ) then
		ModSettingSetNextValue( mod_setting_get_id(mod_id,setting), not value, false )
	end

	mod_setting_tooltip( mod_id, gui, in_main_menu, setting )
end


function mod_setting_all_to_default_button( mod_id, gui, in_main_menu, im_id, setting )
	local value = ModSettingGetNextValue( mod_setting_get_id(mod_id,setting) )

	local text = setting.ui_name
	if setting._clicks == 1 then
		text = text .. " [click again if you're sure]"
	elseif setting._clicks == 2 then
		text = text .. " [once more if you're REALLY sure...]"
	end

	local x = mod_setting_group_x_offset
	if setting._x_margin ~= nil then
		x = x + setting._x_margin
	end

	if GuiButton( gui, im_id, x, 0, text ) then
		if setting._clicks == nil then
			setting._clicks = 1
		elseif setting._clicks == 1 then
			setting._clicks = 2
		elseif setting._clicks == 2 then
			setting._clicks = nil
			print("BOOOOM")
			mod_set_all_to_default()
		end
	end

	mod_setting_tooltip( mod_id, gui, in_main_menu, setting )
end

function mod_set_all_to_default ()
	for _, setting in pairs(vanilla_perk_settings) do
		if (setting.not_setting == nil or setting.not_setting == false) then
			--print("DEFAULT SET FOR " .. mod_setting_get_id(mod_id,setting) .. " => (" .. type(setting.value_default) .. ") " .. tostring(setting.value_default))
			ModSettingSetNextValue( mod_setting_get_id(mod_id,setting), setting.value_default, false )
			if (setting.hidden == true) then
				setting.hidden = false
			end
		end
	end
end

function mod_setting_bool_perk_header( mod_id, gui, in_main_menu, im_id, setting )
	-- unsure what the implications of "re using image ids" would be, it's warned against but there
	-- doesn't seem to be a way to use more than in a ui_fn. Maybe i could fix that but I care not
	-- since it seems to work just fine lol
	GuiLayoutAddVerticalSpacing(gui, 2) -- just a chooch
	local value = ModSettingGetNextValue( mod_setting_get_id(mod_id,setting) )
	local text = setting.ui_name .. ( value and "" or " - REMOVED" )

	GuiImage( gui, im_id, 0, 0, setting.ui_icon, 1, 1, 0 )
	GuiLayoutAddVerticalSpacing(gui, -13.5)

	if not value then 
		GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
	end


	if GuiButton( gui, im_id, mod_setting_group_x_offset - 4, 0, "      " .. text ) then
	--if GuiButton( gui, im_id, mod_setting_group_x_offset + 15, 0, text ) then
		ModSettingSetNextValue( mod_setting_get_id(mod_id,setting), not value, false )
		setting._siblings.max_stack.hidden = value;
		setting._siblings.pool.hidden = value;
		setting._siblings.start.hidden = value;
	end

	GuiLayoutAddVerticalSpacing(gui, 4)
	mod_setting_tooltip( mod_id, gui, in_main_menu, setting )
end

function mod_setting_no_stack( mod_id, gui, in_main_menu, im_id, setting )
	GuiLayoutBeginHorizontal( gui, 0, 0 )
	GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
	GuiText( gui, mod_setting_group_x_offset + setting._x_margin, 0, setting.ui_name )
	GuiLayoutEnd( gui )
end

function mod_setting_stack_slider( mod_id, gui, in_main_menu, im_id, setting )
	local value = ModSettingGetNextValue( mod_setting_get_id(mod_id,setting) )
	if type(value) ~= "number" then value = setting.value_default or 0.0 end

	local fmt = value == 0 and "  NO LIMIT" or "  $0" -- TODO - should say "None" for "start with"
	local x_margin = mod_setting_group_x_offset + setting._x_margin

	GuiText(gui, x_margin, 0, setting.ui_name)
	GuiLayoutAddVerticalSpacing(gui, -1.5)
	local value_new = GuiSlider( gui, im_id, x_margin + 62, -8, "", value, setting.value_min, setting.value_max, setting.value_default, 1, fmt, 64 )
	if value ~= value_new then
		ModSettingSetNextValue( mod_setting_get_id(mod_id,setting), value_new, false )
		mod_setting_handle_change_callback( mod_id, gui, in_main_menu, setting, value, value_new )
	end
	GuiLayoutAddVerticalSpacing(gui, 3)

	mod_setting_tooltip( mod_id, gui, in_main_menu, setting )
end




function mod_setting_change_callback( mod_id, gui, in_main_menu, setting, old_value, new_value  )
	-- TODO - okay whaty
	print( tostring(new_value) )
end

local perks_sorted = function ()
	-- first, make a table with all the names as keys AND a list of names.
	local name_to_perk = {}
	local names = {}
	for _, perk in pairs(perk_list) do
		local name = GameTextGet(perk.ui_name)
		name_to_perk[name] = perk
		table.insert(names, name)
	end

	-- then sort the names
	table.sort(names, function (a, b) return a < b end)

	-- THEN return an iterator
	local i = 0
	return function ()
		i = i+1
		return names[i], name_to_perk[names[i]]
	end
end


for name, perk in perks_sorted() do
	local s_enabled
	local s_start
	local s_max_stack
	local s_pool
	local siblings = {}


	--print(name)
	--print("  - STACKABLE " .. tostring(perk.stackable))
	--print("  - MAX_STACK " .. tostring(perk.stackable_maximum))
	--print("  - POOL " .. tostring(perk.max_in_perk_pool))

	local d_stackable = perk.stackable 
	if d_stackable and perk.stackable_maximum == nil and perk.max_in_perk_pool == nil then
		--print ("!!!!!!!! NIL STACKABLE !!!!!!!!!!!")
	end

	
	local d_max_stack = 1
	-- if not d_stackable then print ("" .. name .. " NO STACK! ") end


	s_enabled = {
		id = "PC_ENABLED_" .. perk.id,
		value_default = true,
		ui_name = name,
		ui_description = "Whether " .. name  .. " will appear in the perk pool",
		ui_fn = mod_setting_bool_perk_header,
		ui_icon = perk.ui_icon,
		scope = MOD_SETTING_SCOPE_NEW_GAME,
		_pc_enabled = true,
		_siblings = siblings,

	}

	local start_hidden = ModSettingGet(mod_setting_get_id(mod_id, s_enabled))
	if (start_hidden == nil) then
		start_hidden = true
	else
		start_hidden = not start_hidden
	end

	if d_stackable then
		local stack_default = perk.stackable_maximum
		if stack_default == nil then stack_default = 0 end
		s_max_stack = {
			id = "PC_STACK_" .. perk.id,
			ui_name = "Stackable to",
			ui_description = "How man times " .. name .. " can be stacked",
			scope = MOD_SETTING_SCOPE_NEW_GAME,
			value_default = stack_default,
			value_min = 0,
			value_max = 32,
			ui_fn = mod_setting_stack_slider,
			hidden = start_hidden,
			_x_margin = 8,
			_siblings = siblings,
		}

		s_start = {
			id = "PC_START_" .. perk.id,
			ui_name = "Start With",
			ui_description = "How many pickups of " .. name .. " should the player start with",
			scope = MOD_SETTING_SCOPE_NEW_GAME,
			value_default = 0,
			value_min = 0,
			value_max = 32,
			ui_fn = mod_setting_stack_slider,
			hidden = start_hidden,
			_x_margin = 8,
			_siblings = siblings,
		}
	else
		s_max_stack = {
			id = "PC_STACK_" .. perk.id,
			ui_name = "[Not Stackable]",
			not_setting = true,
			ui_fn = mod_setting_no_stack,
			hidden = start_hidden,
			_x_margin = 8,
			_siblings = siblings,
		}

		s_start = {
			id = "PC_START_" .. perk.id,
			ui_name = "Start With",
			ui_description = "How many pickups of " .. name .. " should the player start with",
			scope = MOD_SETTING_SCOPE_NEW_GAME,
			value_default = 0,
			ui_fn = function (mod_id, gui, in_main_menu, im_id, setting )
				local value = ModSettingGetNextValue( mod_setting_get_id(mod_id,setting) )
				local text = setting.ui_name .. ((value == 1) and " One" or " None")
				local x = mod_setting_group_x_offset
				if setting._x_margin ~= nil then
					x = x + setting._x_margin
				end

				if value == 0 then
					GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
				end
				if GuiButton( gui, im_id, x, 0, text ) then
					-- local nextValue = value ~ 1 -- this lua too old for bitwiseing? idk
					local nextValue = value == 1 and 0 or 1
					ModSettingSetNextValue( mod_setting_get_id(mod_id,setting), nextValue, false )
				end

				mod_setting_tooltip( mod_id, gui, in_main_menu, setting )
			end,

			hidden = start_hidden,
			_x_margin = 8,
			_siblings = siblings,
		}
	end

	local pool_default = perk.max_in_perk_pool
	if pool_default == nil then pool_default = 0 end

	s_pool = {
		id = "PC_POOL_" .. perk.id,
		ui_name = "Number in Pool",
		ui_description = "How many times " .. name .. " can appear in the pool.\n",
		scope = MOD_SETTING_SCOPE_NEW_GAME,
		value_default = pool_default,
		value_min = 0,
		value_max = 32,
		ui_fn = mod_setting_stack_slider,
		hidden = start_hidden,
		_x_margin = 8,
	}

	siblings.enabled = s_enabled
	siblings.start = s_start
	siblings.max_stack = s_max_stack
	siblings.pool = s_pool

	table.insert(vanilla_perk_settings, s_enabled)
	table.insert(vanilla_perk_settings, s_max_stack)
	table.insert(vanilla_perk_settings, s_pool)
	table.insert(vanilla_perk_settings, s_start)

end

local general_settings = {
	category_id = "general",
	ui_name = "GENERAL SETTINGS",
	_folded = false,
	foldable = true,
	settings = {
		{
			id = "_",
			not_setting = true,
			ui_name = "RESET ALL PERKS TO DEFAULT",
			ui_description = "Revert all perk behavior to vanilla settings.",
			value_default = false,
			scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
			ui_fn = mod_setting_all_to_default_button,

		},
		{
			id = "warn_unrecognized",
			ui_name = "warn on unrecognized perks",
			ui_description = "Print a message at startup for unrecognized perks.\nAnything not in the default perk_list.lua needs\nto be added manually. (TODO)",
			value_default = false,
			scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
			ui_fn = mod_setting_bool_custom, -- custom widget

		},
	}
}

mod_settings = {
	general_settings,

	{
		category_id = "vanilla_perks",
		ui_name = "VANILLA PERKS",
		_folded = false,
		foldable = true,
		settings = vanilla_perk_settings
	}
	
}

-- This function is called to ensure the correct setting values are visible to the game via ModSettingGet(). your mod's settings don't work if you don't have a function like this defined in settings.lua.
-- This function is called:
--		- when entering the mod settings menu (init_scope will be MOD_SETTINGS_SCOPE_ONLY_SET_DEFAULT)
-- 		- before mod initialization when starting a new game (init_scope will be MOD_SETTING_SCOPE_NEW_GAME)
--		- when entering the game after a restart (init_scope will be MOD_SETTING_SCOPE_RESTART)
--		- at the end of an update when mod settings have been changed via ModSettingsSetNextValue() and the game is unpaused (init_scope will be MOD_SETTINGS_SCOPE_RUNTIME)
function ModSettingsUpdate( init_scope )
	local old_version = mod_settings_get_version( mod_id ) -- This can be used to migrate some settings between mod versions.

	for _, setting in pairs(vanilla_perk_settings) do
		if setting._pc_enabled ~= nil then
			local value = ModSettingGetNextValue( mod_setting_get_id(mod_id,setting) )
			--print(tostring(init_scope) .. ": " .. setting.ui_name .. ' => ' .. tostring(value))

			for _, sib in pairs(setting._siblings) do
				if sib._pc_enabled == nil then
					sib.hidden = not value
				end
			end
		end
	end
	-- um idk

	mod_settings_update( mod_id, mod_settings, init_scope )
end

-- This function should return the number of visible setting UI elements.
-- Your mod's settings wont be visible in the mod settings menu if this function isn't defined correctly.
-- If your mod changes the displayed settings dynamically, you might need to implement custom logic.
-- The value will be used to determine whether or not to display various UI elements that link to mod settings.
-- At the moment it is fine to simply return 0 or 1 in a custom implementation, but we don't guarantee that will be the case in the future.
-- This function is called every frame when in the settings menu.
function ModSettingsGuiCount()
	local result = mod_settings_gui_count( mod_id, mod_settings )
	return result
end

-- TODO I dont think i need this
function _pc_mod_settings_gui_count( mod_id, settings )
	local result = 0

	for i,setting in ipairs(settings) do
		if setting.category_id ~= nil then
			result = result + mod_settings_gui_count( mod_id, setting.settings )
		else

			local visible = (setting.hidden == nil or not setting.hidden)
			if visible then
				result = result + (setting._count ~= nil and setting._count or 1)
			end
		end
	end

	return result
end


-- This function is called to display the settings UI for this mod. Your mod's settings wont be visible in the mod settings menu if this function isn't defined correctly.
function ModSettingsGui( gui, in_main_menu )
	mod_settings_gui( mod_id, mod_settings, gui, in_main_menu )

	--example usage:
	--[[
	local im_id = 124662 -- NOTE: ids should not be reused like we do below
	GuiLayoutBeginLayer( gui )

	GuiLayoutBeginHorizontal( gui, 10, 50 )
    GuiImage( gui, im_id + 12312535, 0, 0, "data/particles/shine_07.xml", 1, 1, 1, 0, GUI_RECT_ANIMATION_PLAYBACK.PlayToEndAndPause )
    GuiImage( gui, im_id + 123125351, 0, 0, "data/particles/shine_04.xml", 1, 1, 1, 0, GUI_RECT_ANIMATION_PLAYBACK.PlayToEndAndPause )
    GuiLayoutEnd( gui )

	GuiBeginAutoBox( gui )

	GuiZSet( gui, 10 )
	GuiZSetForNextWidget( gui, 11 )
	GuiText( gui, 50, 50, "Gui*AutoBox*")
	GuiImage( gui, im_id, 50, 60, "data/ui_gfx/game_over_menu/game_over.png", 1, 1, 0 )
	GuiZSetForNextWidget( gui, 13 )
	GuiImage( gui, im_id, 60, 150, "data/ui_gfx/game_over_menu/game_over.png", 1, 1, 0 )

	GuiZSetForNextWidget( gui, 12 )
	GuiEndAutoBoxNinePiece( gui )

	GuiZSetForNextWidget( gui, 11 )
	GuiImageNinePiece( gui, 12368912341, 10, 10, 80, 20 )
	GuiText( gui, 15, 15, "GuiImageNinePiece")

	GuiBeginScrollContainer( gui, 1233451, 500, 100, 100, 100 )
	GuiLayoutBeginVertical( gui, 0, 0 )
	GuiText( gui, 10, 0, "GuiScrollContainer")
	GuiImage( gui, im_id, 10, 0, "data/ui_gfx/game_over_menu/game_over.png", 1, 1, 0 )
	GuiImage( gui, im_id, 10, 0, "data/ui_gfx/game_over_menu/game_over.png", 1, 1, 0 )
	GuiImage( gui, im_id, 10, 0, "data/ui_gfx/game_over_menu/game_over.png", 1, 1, 0 )
	GuiImage( gui, im_id, 10, 0, "data/ui_gfx/game_over_menu/game_over.png", 1, 1, 0 )
	GuiLayoutEnd( gui )
	GuiEndScrollContainer( gui )

	local c,rc,hov,x,y,w,h = GuiGetPreviousWidgetInfo( gui )
	print( tostring(c) .. " " .. tostring(rc) .." " .. tostring(hov) .." " .. tostring(x) .." " .. tostring(y) .." " .. tostring(w) .." ".. tostring(h) )

	GuiLayoutEndLayer( gui )
	]]--
end
