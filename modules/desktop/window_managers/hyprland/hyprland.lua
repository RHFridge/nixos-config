-- ~/.config/hypr/hyprland.lua
-- Converted from hyprlang (hyprland.conf) to Hyprland's Lua config (0.55+).
-- hyprlang is deprecated as of 0.55 but should still work for 1-2 more
-- releases if you want to sanity-check behaviour differences.

local mainMod  = "SUPER"
local browser  = "firefox"
local files    = "nautilus"
local menu     = "rofi -show drun"
local term     = "alacritty"

-- ===========================================================================
-- Autostart (exec-once)
-- ===========================================================================
hl.on("hyprland.start", function()
  hl.exec_cmd("/nix/store/hb0kkjdwmzfbrlslvd7c59k8y3lq0w0w-dbus-1.16.2/bin/dbus-update-activation-environment --systemd --all && systemctl --user stop hyprland-session.target && systemctl --user start hyprland-session.target")
  hl.exec_cmd("noctalia")
end)

-- ===========================================================================
-- General / animations / input / misc
-- ===========================================================================
hl.config({
  general = {
    border_size = 2,
    gaps_in = 10,
    gaps_out = 2,
  },
  animations = {
    enabled = false,
  },
  input = {
    kb_layout = "gb",
  },
  misc = {
    vrr = 2,
  },
  render = {
    direct_scanout = 2,
  },
})

-- ===========================================================================
-- Monitors
-- ===========================================================================
hl.monitor({
  output = "",
  mode = "highrr",
  position = "auto",
  scale = 1,
})

-- ===========================================================================
-- Window rules (borderless / no rounding on single-window or maximized ws)
-- ===========================================================================
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, rounding = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, rounding = 0 })

-- ===========================================================================
-- Workspace rules (no gaps on single-window / fullscreen workspaces)
-- ===========================================================================
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })

-- ===========================================================================
-- Keybinds
-- ===========================================================================
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(term))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(files))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("noctalia msg session lock"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("noctalia msg notification-invoke-latest"))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))

hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("noctalia msg screenshot-region"))

-- media / FN keys (no modkey)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("noctalia msg volume-up"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("noctalia msg volume-down"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("noctalia msg volume-mute"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("noctalia msg brightness-up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("noctalia msg brightness-down"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("noctalia msg mic-mute"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("noctalia msg mic-mute"))

-- cursor zoom on SUPER + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.exec_cmd([[hyprctl keyword cursor:zoom_factor "$(hyprctl getoption cursor:zoom_factor | grep float | awk '{print $2 + 0.5}')"]]))
hl.bind(mainMod .. " + mouse_up", hl.dsp.exec_cmd([[hyprctl keyword cursor:zoom_factor "$(hyprctl getoption cursor:zoom_factor | grep float | awk '{print $2 - 0.5}')"]]))
hl.bind(mainMod .. " + SHIFT + Z", hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor 1"))

-- window management
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd([[hyprctl activewindow | grep pid | tr -d 'pid:' | xargs kill]]))

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))

-- workspaces 1-10 (0 = workspace 10)
for i = 1, 10 do
  local key = i % 10
  local ws  = i
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = ws }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = ws }))
end

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
-- workspaceopt allfloat has no confirmed 1:1 hl.dsp call yet as of this writing;
-- falling back to a raw exec. Worth re-checking the wiki's Dispatchers page
-- for a native hl.dsp.workspace.* equivalent as the Lua API matures.
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("hyprctl dispatch workspaceopt allfloat"))

hl.bind(mainMod .. " + U", hl.dsp.layout("togglesplit"))

hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.resize({ x = -100, y = 0 }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.resize({ x = 100, y = 0 }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.resize({ x = 0, y = -100 }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.resize({ x = 0, y = 100 }))

hl.bind(mainMod .. " + I", hl.dsp.layout("swapsplit"))

-- swapwindow: hl.dsp.window.swap({direction=...}) mirrors the window.move()
-- naming pattern seen elsewhere in the API, but I could not find a fully
-- confirmed reference example for it — double-check against the wiki.
hl.bind(mainMod .. " + ALT + H", hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + ALT + L", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + ALT + K", hl.dsp.window.swap({ direction = "u" }))
hl.bind(mainMod .. " + ALT + J", hl.dsp.window.swap({ direction = "d" }))

hl.bind(mainMod .. " + F8", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" }))

-- ALT+Tab cycling
hl.bind("ALT + Tab", hl.dsp.window.cycle_next(), { repeating = true })
hl.bind("ALT + Tab", hl.dsp.window.bring_to_top(), { repeating = true })

-- mouse move/resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
