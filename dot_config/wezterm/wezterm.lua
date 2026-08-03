-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- plugins
local cmdpicker = wezterm.plugin.require('https://github.com/abidibo/wezterm-cmdpicker')

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

config.hide_tab_bar_if_only_one_tab = true
config.window_close_confirmation = 'NeverPrompt'
config.default_prog = { '/usr/bin/fish', '-l' }
config.scrollback_lines = 50000
config.font_size = 10
config.font = wezterm.font '0xProto Nerd Font'

-- plugin conf
cmdpicker.apply_to_config(config, {
title = 'Command Palette',
})

config.keys = {
  { key = 'C', mods = 'LEADER', action = wezterm.action.ActivateCopyMode },
}
config.leader = { key = 'Space', mods = 'CTRL' }

-- Finally, return the configuration to wezterm:
return config
