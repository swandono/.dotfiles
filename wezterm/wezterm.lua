local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font = wezterm.font("FiraCode Nerd Font Mono")
config.font_size = 13.5

config.enable_tab_bar = false

config.window_decorations = "RESIZE"

config.colors = {
	foreground = "#abb2bf",
	background = "#051431",
	selection_fg = " #abb2bf",
	selection_bg = "#323844",
	cursor_bg = "#8a94a9",
	cursor_border = "#8a94a9",
	cursor_fg = "#e8e8e8",
	ansi = {
		"#131d2c",
		"#e5646e",
		"#89d354",
		"#e4b763",
		"#2677c9",
		"#c678dd",
		"#32d4e8",
		"#abb2bf",
	},
	brights = {
		"#3a445a",
		"#e5646e",
		"#8ac16f",
		"#e4b763",
		"#38a3e9",
		"#c678dd",
		"#32d4e8",
		"#abb2bf",
	},
}

config.window_background_opacity = 0.825
config.macos_window_background_blur = 35

return config
