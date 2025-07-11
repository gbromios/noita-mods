dofile("data/scripts/lib/mod_settings.lua") -- see this file for documentation on some of the features.

-- Settings will be automatically saved.
-- Settings don't have access unsafe lua APIs.

-- Use ModSettingGet() in the game to query settings.
-- For some settings (for example those that affect world generation) you might want to retain the current value until a certain point, even
-- if the player has changed the setting while playing.
-- To make it easy to define settings like that, each setting has a "scope" (e.g. MOD_SETTING_SCOPE_NEW_GAME) that will define when the changes
-- will actually become visible via ModSettingGet(). In the case of MOD_SETTING_SCOPE_NEW_GAME the value at the start of the run will be visible
-- until the player starts a new game.
-- ModSettingSetNextValue() will set the buffered value, that will later become visible via ModSettingGet(), unless the setting scope is MOD_SETTING_SCOPE_RUNTIME.
function ModSettingsGuiCount()
  return 1
end

mod_settings = {
  {
    id = "backpack_pages",
    ui_name = "Number of pages for wands/items/spells",
    ui_description = "Pages",
    value_default = 4,
    value_min = 2,
    value_max = 32,
    value_display_multiplier = 1,
    value_display_formatting = " $0 Pages",
    scope = MOD_SETTING_SCOPE_NEW_GAME,
  },
}

function ModSettingsUpdate( init_scope )
	mod_settings_update('backpack_gb', mod_settings, init_scope)
end

function ModSettingsGui( gui, in_main_menu )
	mod_settings_gui('backpack_gb', mod_settings, gui, in_main_menu)
end
