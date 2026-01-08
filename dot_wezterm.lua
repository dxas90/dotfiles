local wezterm = require("wezterm")
local mux = wezterm.mux
local config = {}

wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.term = "xterm-256color"
config.hide_tab_bar_if_only_one_tab = true

config.default_prog = { '/bin/bash' }

config.font = wezterm.font("Hack Nerd Font Mono")

config.font_size = 16

config.window_padding = {
    top = 10,
    bottom = 10,
    left = 10,
    right = 10,
}

config.color_scheme = "Catppuccin Mocha"

config.window_background_opacity = 0.88

config.window_decorations = "RESIZE"

config.window_background_gradient = {
	interpolation = "Linear",

	orientation = "Vertical",

	blend = "Rgb",

	colors = {
		"#11111b",
		"#181825",
	},
}
--config.mux_enable_ssh_agent = false

local direction_keys = {
    h = "Left",
    j = "Down",
    k = "Up",
    l = "Right",
}

local function split_nav(key)
    return {
        key = key,
        mods = "CTRL",
        action = wezterm.action_callback(function(win, pane)
            if pane:Get_users_vars().IS_NVIM == "true" then
                -- pass the keys through to vim/nvim
                win:perform_action({
                    SendKey = { key = key, mods = "CTRL" },
                }, pane)
            else
                win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
            end
        end),
    }
end

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 }

local action = wezterm.action

config.keys = {
    {
        key = "\\",
        mods = "LEADER",
        action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
    },
    split_nav("h"),
    split_nav("j"),
    split_nav("k"),
    split_nav("l"),
    {
        key = "h",
        mods = "CTRL|SHIFT",
        action = action.AdjustPaneSize({ "Left", 5 }),
    },
    {
        key = "l",
        mods = "CTRL|SHIFT",
        action = action.AdjustPaneSize({ "Right", 5 }),
    },
    {
        key = "j",
        mods = "CTRL|SHIFT",
        action = action.AdjustPaneSize({ "Down", 5 }),
    },
    {
        key = "k",
        mods = "CTRL|SHIFT",
        action = action.AdjustPaneSize({ "Up", 5 }),
    },
    {
        key = "-",
        mods = "LEADER",
        action = action.SplitVertical({ domain = "CurrentPaneDomain" }),
    },
    {
        key = "m",
        mods = "LEADER",
        action = action.TogglePaneZoomState,
    },
    { key = "[", mods = "LEADER", action = action.ActivateCopyMode },
    {
        key = "c",
        mods = "LEADER",
        action = action.SpawnTab("CurrentPaneDomain"),
    },

    {
        key = "p",
        mods = "LEADER",
        action = action.ActivateTabRelative(-1),
    },
    {
        key = "n",
        mods = "LEADER",
        action = action.ActivateTabRelative(1),
    },
}

for i = 1, 9 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = "LEADER",
        action = action.ActivateTab(i - 1),
    })
end

config.mux_env_remove = {
	"SSH_AUTH_SOCK",
	"SSH_CLIENT",
	"SSH_CONNECTION",
}

config.front_end = "WebGpu"

return config
