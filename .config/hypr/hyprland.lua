-- ──────────────────────────────────────────────
--   Hyprland Configuration — Lua (0.55+)
--   Migrated from hyprland.conf · Intel Celeron N4020 · UHD 600 · 8 GB RAM
--   Preserves all original semantics; theme delegated to theme.lua/colors.lua
--   See wiki.hypr.land + /usr/share/hypr/stubs/hl.meta.lua for API details
-- ──────────────────────────────────────────────

-- ── Monitor ──────────────────────────────────
hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "0x0", scale = 1 })

-- ── Environment ──────────────────────────────
hl.env("XCURSOR_SIZE", "20")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")

-- ── Default Programs ─────────────────────────
local terminal = "kitty"
local browser  = "brave"
local menu     = "rofi -show drun"
local file     = "thunar"

-- ── Input ────────────────────────────────────
hl.config({
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            drag_lock = true,
        },
    },
})

-- ── Theme (was: source = ~/.config/hypr/colors.conf / theme.conf) ──
-- In 0.55 `source` → `require("module")`. Each file shares the `hl` global.
-- Keep both hyprlang .conf and new Lua .lua on disk for rollback; Lua wins when present.
-- Matugen now writes colors.lua (see matugen/templates/hyprland.lua); theme.lua is a
-- symlink to the active theme in hypr/themes/*/theme.lua (managed by theme-selector.sh)
pcall(require, "colors")
pcall(require, "theme")

-- ── Autostart (was exec-once) ────────────────
hl.on("hyprland.start", function()
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("waybar")
    hl.exec_cmd("dunst")
    hl.exec_cmd(terminal)
end)

-- ── Animations ───────────────────────────────
hl.config({
    animations = {
        enabled = false,
    },
})
-- Bezier (was inside animations { bezier = ... })
hl.curve("easeOutExpo", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
-- Animations per leaf (were: animation = windows, 1, 3, easeOutExpo, popin 80% etc.)
hl.animation({ leaf = "windows",    enabled = true, speed = 3, bezier = "easeOutExpo", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "easeOutExpo", style = "popin 80%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3, bezier = "easeOutExpo" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "easeOutExpo", style = "slide" })

-- ── Layouts ──────────────────────────────────
hl.config({
    dwindle = {
        -- pseudotile removed in 0.55 (use window rule or dispatcher `pseudo` instead)
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
})

-- ── Misc / Render / Debug ────────────────────
hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        animate_manual_resizes = false,
        initial_workspace_tracking = false,
    },
    render = {
        direct_scanout = true, -- was misc.no_direct_scanout (inverted)
    },
    debug = {
        disable_logs = true,
        -- vfr moved here from misc.vfr (0.55)
        vfr = true,
    },
})

-- ── Keybinds ─────────────────────────────────
local mod = "SUPER"

-- Default programs
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + Space",  hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + Q",      hl.dsp.window.close())               -- was killactive (graceful close)
hl.bind(mod .. " + SHIFT + E", hl.dsp.exit())
hl.bind(mod .. " + F",      hl.dsp.window.fullscreen())           -- was fullscreen, 0
hl.bind(mod .. " + V",      hl.dsp.window.float({ action = "toggle" })) -- togglefloating
hl.bind(mod .. " + P",      hl.dsp.window.pseudo())               -- pseudo
hl.bind(mod .. " + J",      hl.dsp.layout("togglesplit"))         -- togglesplit (layoutmsg)
hl.bind(mod .. " + B",      hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + E",      hl.dsp.exec_cmd(file))
hl.bind(mod .. " + C",      hl.dsp.exec_cmd("libreoffice --writer"))
hl.bind(mod .. " + T",      hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/theme-selector.sh"))
hl.bind(mod .. " + R",      hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/random-wall.sh"))
hl.bind(mod .. " + W",      hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/waybar/scripts/theme-selector.sh"))
hl.bind(mod .. " + SHIFT + T", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/global-theme-selector.sh"))

-- Move focus (Vim-style)
hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Resize windows (Arrow keys) — binde → { repeating = true }
hl.bind(mod .. " + left",  hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + right", hl.dsp.window.resize({ x = 20,  y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + up",    hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind(mod .. " + down",  hl.dsp.window.resize({ x = 0, y = 20,  relative = true }), { repeating = true })

-- Switch workspaces (was 9 explicit binds — loop is idiomatic Lua, same effect)
for i = 1, 9 do
    hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
end

-- Move active window to workspace
for i = 1, 9 do
    hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through workspaces (mouse wheel)
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mouse (was bindm)
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume & brightness (media keys) — bindel/bindl → { repeating, locked }
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),  { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),  { repeating = true, locked = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 5%+"),                         { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"),                         { repeating = true, locked = true })

-- Screenshot (requires grim + slurp)
hl.bind("Print",             hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
hl.bind(mod .. " + Print",   hl.dsp.exec_cmd("grim - | wl-copy"))

-- ── Window Rules ─────────────────────────────
hl.window_rule({
    name = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})
