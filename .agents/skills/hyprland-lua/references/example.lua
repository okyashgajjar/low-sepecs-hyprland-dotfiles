-- Idiomatic Hyprland Lua config example
-- Split into modules via require(); each file shares the `hl` global.
-- See https://wiki.hypr.land/ and /usr/share/hypr/stubs/hl.meta.lua for exact API.

require("theme")    -- colors, animations, decoration
require("rules")    -- window_rule / workspace_rule / layer_rule
require("binds")    -- keybindings

-- ─── Monitors ───────────────────────────────────────────────────────────────

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

-- ─── Input ──────────────────────────────────────────────────────────────────

hl.config({
    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = { natural_scroll = true, tap_to_click = true },
    },
    general = {
        gaps_in      = 5,
        gaps_out     = 10,
        border_size  = 2,
        layout       = "dwindle",
        resize_on_border = true,
    },
    dwindle = { preserve_split = true },
    misc = {
        disable_hyprland_logo = true,
        disable_autoreload    = false,
    },
})

-- ─── Autostart ──────────────────────────────────────────────────────────────

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("nm-applet --indicator")
end)

-- ─── Keybindings (inline — no separate file) ────────────────────────────────

local mod = "SUPER"

-- Emergency exits — define early so they survive any later error
hl.bind(mod .. " + Q",           hl.dsp.exec_cmd("kitty"))
hl.bind(mod .. " + M",           hl.dsp.exit())
hl.bind(mod .. " + SHIFT + R",   hl.dsp.exec_cmd("hyprctl reload"))

-- Common actions
hl.bind(mod .. " + C",           hl.dsp.window.close())
hl.bind(mod .. " + E",           hl.dsp.exec_cmd("thunar"))
hl.bind(mod .. " + R",           hl.dsp.exec_cmd("fuzzel"))
hl.bind(mod .. " + V",           hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + P",           hl.dsp.window.pseudo())
hl.bind(mod .. " + F",           hl.dsp.window.fullscreen())

-- Focus
hl.bind(mod .. " + left",        hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right",       hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",          hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down",        hl.dsp.focus({ direction = "down" }))

-- Workspaces 1-10
for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key,             hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad
hl.bind(mod .. " + S",           hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(mod .. " + SHIFT + S",   hl.dsp.window.move({ workspace = "special:scratchpad" }))

-- Mouse
hl.bind(mod .. " + mouse:272",   hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273",   hl.dsp.window.resize(), { mouse = true })

-- Media keys (work on lockscreen)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"),  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"),  { locked = true, repeating = true })

-- Resize submap
hl.define_submap("resize", "ESCAPE", function()
    hl.bind("left",  hl.dsp.window.resize({ direction = "left",  delta = 30 }), { repeating = true })
    hl.bind("right", hl.dsp.window.resize({ direction = "right", delta = 30 }), { repeating = true })
    hl.bind("up",    hl.dsp.window.resize({ direction = "up",    delta = 30 }), { repeating = true })
    hl.bind("down",  hl.dsp.window.resize({ direction = "down",  delta = 30 }), { repeating = true })
end)
hl.bind(mod .. " + SHIFT + RETURN", hl.dsp.submap("resize"))

-- ─── Window rules ───────────────────────────────────────────────────────────

-- Rule property names (float, no_focus, move, size, etc.) come from the wiki,
-- not the stubs — HL.WindowRuleSpec only defines name/match/enabled in typed stubs.
hl.window_rule({
    name  = "float-dialogs",
    match = { title = "^(Open|Save|Confirmation|Progress).*" },
    float = true,
})

hl.window_rule({
    name  = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix XWayland undecorated drag-handles
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false },
    no_focus = true,
})

-- ─── Event-driven logic ─────────────────────────────────────────────────────

-- Notify on window open (debug/demo — remove in production)
hl.on("window.open", function(win)
    -- win is HL.Window; fields: class, title, pid, address, workspace, monitor …
    hl.notification.create({
        text    = "Opened: " .. (win.class or "?"),
        timeout = 2,
    })
end)

-- React to monitor hotplug
hl.on("monitor.added", function(mon)
    hl.monitor({ output = mon.name, mode = "preferred", position = "auto", scale = "auto" })
end)
