dofile('data/scripts/lib/mod_settings.lua') -- see this file for documentation on some of the features.

-- MOD_SETTING_SCOPE_RUNTIME -- we awant

-- MOD_SETTING_SCOPE_RUNTIME_RESTART

local mod_id = 'hp_regen'
mod_settings_version = 1

function sid (id) return mod_id .. '.' .. id end
function show_heal ()
  return ModSettingGetNextValue(sid('enable_heal'))
end
function show_dcd ()
  return ModSettingGetNextValue(sid('enable_damage_cd'))
end
function show_crit ()
  return ModSettingGetNextValue(sid('enable_crit'))
end

function show_crit_mod ()
  return show_crit() and show_heal()
end

function mod_setting_text (setting)
  local text = setting.ui_name .. ': ' .. setting.ui_description
  local _, lines = string.gsub(text, '\n', '')
  local x = mod_setting_group_x_offset + 1.5 -- we groupin
  local y = (lines + 1) * 2
  --print('text?', text, x, y)
  return text, x, y
end

function mod_setting_percent_hp (mod_id, gui, in_main_menu, im_id, setting)
  if setting.show_if and not setting.show_if() then return end
	local value = ModSettingGetNextValue( mod_setting_get_id(mod_id,setting) )
	if type(value) ~= 'number' then value = setting.value_default or 0.0 end
  local text, x, y = mod_setting_text(setting)
  GuiText(gui, x, 0, text)
	local value_new = GuiSlider(
    gui,
    im_id,
    x,
    y,
    '', -- setting.ui_name,
    value,
    0,
    1,
    setting.value_default,
    100, -- mult
    '  $0% HP',
    200 -- width
  )
	if value ~= value_new then
		ModSettingSetNextValue(sid(setting.id), value_new, false)
	end

	--mod_setting_tooltip(mod_id, gui, in_main_menu, setting)
  GuiLayoutAddVerticalSpacing(gui, 2)
end

function mod_setting_flat_hp (mod_id, gui, in_main_menu, im_id, setting)
  if setting.show_if and not setting.show_if() then return end
	local value = ModSettingGetNextValue( mod_setting_get_id(mod_id,setting) )
	if type(value) ~= 'number' then value = setting.value_default or 0.0 end

  local text, x, y = mod_setting_text(setting)
  GuiText(gui, x, 0, text)
	local value_new = GuiSlider(
    gui,
    im_id,
    x,
    y,
    '', -- setting.ui_name,
    value,
    0, -- min
    4, -- max (100hp)
    setting.value_default,
    25, -- display multiplier
    '  $0 HP', -- '$0 HP', -- format
    200 -- width
  )

  print('SLIDER SEZ:', value_new)

	if value ~= value_new then
		ModSettingSetNextValue(sid(setting.id), value_new, false)
	end

	--mod_setting_tooltip(mod_id, gui, in_main_menu, setting)
  GuiLayoutAddVerticalSpacing(gui, 2)
end

function mod_setting_mult_hp (mod_id, gui, in_main_menu, im_id, setting)
  if setting.show_if and not setting.show_if() then return end
	local value = ModSettingGetNextValue( mod_setting_get_id(mod_id,setting) )
	if type(value) ~= 'number' then value = setting.value_default or 0.0 end

  local text, x, y = mod_setting_text(setting)
  GuiText(gui, x, 0, text)
	local value_new = GuiSlider(
    gui,
    im_id,
    x,
    y,
    '', -- setting.ui_name,
    value,
    0, -- min
    10, -- max?
    setting.value_default,
    1, -- multiplier
    --'  (normal regen) × $0', -- format
    '  (normal regen) X $0', -- format
    200 -- width
  )

	if value ~= value_new then
		ModSettingSetNextValue(sid(setting.id), value_new, false)
	end

	--mod_setting_tooltip(mod_id, gui, in_main_menu, setting)
  GuiLayoutAddVerticalSpacing(gui, 2)
end

function mod_setting_seconds (mod_id, gui, in_main_menu, im_id, setting)
  if setting.show_if and not setting.show_if() then return end
	local value = ModSettingGetNextValue( mod_setting_get_id(mod_id,setting) )
	if type(value) ~= 'number' then value = setting.value_default or 0.0 end

  local text, x, y = mod_setting_text(setting)
  GuiText(gui, x, 0, text)
	local value_new = GuiSlider(
    gui,
    im_id,
    x,
    y,
    '', -- setting.ui_name,
    value,
    setting.value_min,
    setting.value_max,
    setting.value_default,
    1, -- multiplier
    '', -- '$0 Seconds', -- format
    200 -- width
  )

  --GuiText(text, x, 0)

	if value ~= value_new then
		ModSettingSetNextValue(sid(setting.id), value_new, false)
	end

	--mod_setting_tooltip(mod_id, gui, in_main_menu, setting)
  GuiLayoutAddVerticalSpacing(gui, 2)
end

mod_settings = {
  {
    id = 'heal_tick_s',
    ui_name = 'Healing Interval (seconds)',
    ui_description = 'time between heals',
    value_default = 5,
    change_fn = change_fn,
    ui_fn = mod_setting_seconds,
    scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
    value_min = 1,
    value_max = 60,
  },

  {
    id = 'enable_heal',
    ui_name = 'Enable Regular Healing',
    ui_description = 'whether to activate periodic regeneration.\nIf multiple quantities are set at the same time, they will be added together.\n(e.g.: 10 flat and 10 % will heal 'max * 0.1 + 10' hp',
    value_default = true,
    change_fn = change_fn,
    ui_fn = mod_setting_bool,
    scope = MOD_SETTING_SCOPE_RUNTIME,
    value_max = 5000,
  },
  {
    id = 'heal_percent',
    ui_name = 'Percent-Based Healing',
    ui_description = 'heal a percent of max health each tick',
    value_default = 0.05,
    change_fn = change_fn,
    ui_fn = mod_setting_percent_hp,
    scope = MOD_SETTING_SCOPE_RUNTIME,
    show_if = show_heal,
  },

  {
    id = 'heal_flat',
    ui_name = 'Flat Healing',
    ui_description = 'heal a fixed number of HP value each tick',
    value_default = 0,
    change_fn = change_fn,
    ui_fn = mod_setting_flat_hp,
    scope = MOD_SETTING_SCOPE_RUNTIME,
    show_if = show_heal,
  },

  {
    id = 'enable_crit',
    ui_name = 'Enable Critical Healing',
    ui_description = 'whether to heal more at low health (in addition to normal healing amounts)',
    value_default = false,
    change_fn = change_fn,
    ui_fn = mod_setting_bool,
    --ui_fn = function (mod_id, gui, in_main_menu, im_id, setting)
      --pp(({mod_id, gui, in_main_menu, im_id, setting}))
    --end,
    scope = MOD_SETTING_SCOPE_RUNTIME,
    --value_display_multiplier = 0.04,
    --value_display_formatting = '  $0 HP',
    --value_min = 25,
    --value_max = 5000,
  },

  {
    id = 'crit_threshold',
    ui_name = 'Low-Health Threshold',
    ui_description = '% of health remeaining that constitutes 'Low Health'',
    value_default = 0.2,
    change_fn = change_fn,
    ui_fn = mod_setting_percent_hp,
    show_if = show_crit,
    scope = MOD_SETTING_SCOPE_RUNTIME,
  },

  {
    id = 'crit_flat',
    ui_name = 'Flat Critical Healing',
    ui_description = 'Heals a fixed number of extra HP when health is low.',
    value_default = 0,
    change_fn = change_fn,
    ui_fn = mod_setting_flat_hp,
    show_if = show_crit,
    scope = MOD_SETTING_SCOPE_RUNTIME,
  },

  {
    id = 'crit_percent',
    ui_name = 'Percent-Based Critical Healing',
    ui_description = 'Heals an additional percentage of max hp when\nhealth is low.',
    value_default = 0,
    change_fn = change_fn,
    ui_fn = mod_setting_percent_hp,
    show_if = show_crit,
    scope = MOD_SETTING_SCOPE_RUNTIME,
  },

  {
    id = 'crit_mod',
    ui_name = 'Multiply normal healing amount by a factor',
    ui_description = 'amount to modify normal healing during\nlow hp. if set less than one, it will reduce the healed amount instead!\nSetting to 0 or 1 disables this multiplier.',
    value_default = 2.0,
    change_fn = change_fn,
    ui_fn = mod_setting_mult_hp,
    show_if = show_crit_mod,
    scope = MOD_SETTING_SCOPE_RUNTIME,
  },

  {
    id = 'enable_damage_cd',
    ui_name = 'Enable Damage Cooldown',
    ui_description = 'Whether taking damage imposes extra delay on healing',
    value_default = false,
    change_fn = change_fn,
    ui_fn = mod_setting_bool,
    --ui_fn = function (mod_id, gui, in_main_menu, im_id, setting)
      --pp(({mod_id, gui, in_main_menu, im_id, setting}))
    --end,
    scope = MOD_SETTING_SCOPE_RUNTIME,
    --value_display_multiplier = 0.04,
    --value_display_formatting = '  $0 HP',
    --value_min = 25,
    --value_max = 5000,
  },

  {
    id = 'damage_cd',
    ui_name = 'Damage Cooldown (seconds)',
    ui_description = 'time in seconds that must pass before healing occurs',
    value_default = 10,
    change_fn = change_fn,
    show_if = show_dcd,
    ui_fn = mod_setting_seconds,
    scope = MOD_SETTING_SCOPE_RUNTIME,
    value_min = 1,
    value_max = 180,
  },
}


function ModSettingsGuiCount()
  local count = 4 -- always show the tick time + mode 3 toggles
  if show_heal() then count = count + 2 end
  if show_crit() then count = count + 3 end
  if show_dcd() then count = count + 1 end
  if show_crit_mod() then count = count + 1 end
	return count
end

function ModSettingsGui( gui, in_main_menu )
	mod_settings_gui( mod_id, mod_settings, gui, in_main_menu )
end


function ModSettingsUpdate(init_scope)
  ---print('CALLED: ModSettingsUpdate('.. tostring(init_scope) ..')')
	--local old_version = mod_settings_get_version( mod_id ) -- This can be used to migrate some settings between mod versions.
	mod_settings_update( mod_id, mod_settings, init_scope )
  if init_scope == MOD_SETTING_SCOPE_RUNTIME then
    ---print('WE GO HAMB')
    --apply_settings()
  end
end
