---
name: hyprland-lua
description: >
  Expert knowledge of Hyprland's Lua configuration API (introduced in 0.55).
  Activate when the user asks about hyprland.lua, hl.config(), hl.bind(),
  hl.on() events, hl.dsp dispatchers, window/workspace rules, or any
  Hyprland Lua config task.
  Activate when editing any .lua file under ~/.config/hypr/ (e.g. hyprland.lua,
  binds.lua, rules.lua, theme.lua, or any required module).
  Activate when the user writes or asks about any `hyprctl dispatch` command —
  in shell scripts, CLI, or Lua — because Hyprland 0.55+ requires dispatcher
  arguments to use the Lua hl.dsp.* syntax, not the old keyword form.
---

# Hyprland Lua Config Skill

Hyprland 0.55+ replaces `.conf` files with a Lua-based config. The entrypoint is `~/.config/hypr/hyprland.lua`. The global `hl` object is the entire API — no imports needed.

> **Groundedness rule:** This skill covers stable patterns and conventions. For exact option names, dispatcher argument shapes, and event payloads that may vary between Hyprland versions, **always consult**:
> - `/usr/share/hypr/stubs/hl.meta.lua` — machine-generated stubs for the *running* system (LuaLS-compatible)
> - `https://wiki.hypr.land/` — official documentation

---

## 1. Core API surface

```lua
-- Configuration options (nested table, keys mirror the dotted config path)
hl.config({ general = { gaps_in = 5, border_size = 2 } })

-- Monitor setup
hl.monitor({ output = "DP-1", mode = "2560x1440@165", position = "0x0", scale = 1 })

-- Keybind — second arg is a dispatcher OR a plain Lua function
hl.bind("SUPER + Q", hl.dsp.exec_cmd("kitty"))
hl.bind("SUPER + C", hl.dsp.window.close())
hl.bind("SUPER + F", function() ... end)         -- inline function also valid

-- Event subscription — returns HL.EventSubscription (has :remove())
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
end)

-- Window rule — returns HL.WindowRule (has :set_enabled())
-- match fields: class, title, float, xwayland, fullscreen, pin, workspace, monitor, tag …
-- rule properties: float, no_focus, move, size, suppress_event, etc. — see wiki for full list
hl.window_rule({
    name  = "float-steam",
    match = { class = "^steam$", float = true },
})

-- Workspace rule
hl.workspace_rule({ workspace = "1", monitor = "DP-1" })

-- Per-device config
hl.device({ name = "my-mouse", sensitivity = -0.5 })

-- Environment variables
hl.env("XCURSOR_SIZE", "24")

-- Run a command immediately (not a dispatcher)
hl.exec_cmd("notify-send hello")

-- Timer
hl.timer(function() ... end, { timeout = 5000, type = "oneshot" })
```

---

## 2. The dispatcher namespace (`hl.dsp`)

Dispatchers are values — call them to *create* a dispatcher, then pass it to `hl.bind()` or `hl.dispatch()`.

```lua
-- Top-level dispatchers
hl.dsp.exec_cmd("app")          -- launch app
hl.dsp.exec_raw("raw cmd")      -- raw shell
hl.dsp.exit()                   -- quit Hyprland
hl.dsp.focus({ direction = "left" })         -- focus by direction
hl.dsp.focus({ workspace = 3 })             -- focus workspace
hl.dsp.layout("togglesplit")                -- send message to layout
hl.dsp.submap("resize")                     -- enter a submap
hl.dsp.dpms("toggle")
hl.dsp.pass()

-- Window dispatchers (hl.dsp.window.*)
hl.dsp.window.close()
hl.dsp.window.kill()
hl.dsp.window.float({ action = "toggle" })
hl.dsp.window.fullscreen()
hl.dsp.window.move({ workspace = 2 })
hl.dsp.window.move({ workspace = "special:magic" })
hl.dsp.window.resize()
hl.dsp.window.drag()            -- for mouse binds
hl.dsp.window.pin()
hl.dsp.window.pseudo()
hl.dsp.window.cycle_next()
hl.dsp.window.center()
hl.dsp.window.set_prop(...)     -- see wiki for property names
hl.dsp.window.tag("mytag")
hl.dsp.window.clear_tags()
hl.dsp.window.bring_to_top()

-- Workspace dispatchers (hl.dsp.workspace.*)
hl.dsp.workspace.toggle_special("magic")
hl.dsp.workspace.move(...)
hl.dsp.workspace.rename(...)
hl.dsp.workspace.swap_monitors(...)

-- Group dispatchers (hl.dsp.group.*)
hl.dsp.group.toggle()
hl.dsp.group.lock()
hl.dsp.group.next()
hl.dsp.group.prev()

-- Cursor dispatchers (hl.dsp.cursor.*)
hl.dsp.cursor.move(...)
hl.dsp.cursor.move_to_corner(...)
```

---

## 3. Key types

| Type | Notable fields |
|------|---------------|
| `HL.Window` | `class`, `title`, `pid`, `address`, `floating`, `fullscreen`, `workspace`, `monitor`, `tags`, `pinned`, `xwayland` |
| `HL.Monitor` | `name`, `id`, `width`, `height`, `scale`, `x`, `y`, `refresh_rate`, `focused` |
| `HL.Workspace` | `name`, `id`, `monitor`, `windows`, `active`, `special` |
| `HL.Keybind` | `:set_enabled(bool)`, `:remove()`, `:unbind()` |
| `HL.EventSubscription` | `:is_active()`, `:remove()` |
| `HL.WindowRule` | `:set_enabled(bool)` |
| `HL.Timer` | `:set_enabled(bool)`, `:set_timeout(ms)` |

**Query functions:**

```lua
hl.get_active_window()                  -- HL.Window|nil
hl.get_active_monitor()                 -- HL.Monitor|nil
hl.get_active_workspace()               -- HL.Workspace|nil
hl.get_monitors()                       -- HL.Monitor[]
hl.get_windows({ class = "kitty" })     -- HL.Window[], optional filter
hl.get_workspaces()                     -- HL.Workspace[]
hl.get_window(address)                  -- HL.Window|nil, by address/id/object
hl.get_config("general.gaps_in")        -- reads a live config value
```

---

## 4. Event names

```
config.reloaded      hyprland.start       hyprland.shutdown
window.open          window.open_early    window.close        window.destroy
window.active        window.title         window.class        window.fullscreen
window.move_to_workspace  window.pin      window.urgent       window.update_rules
window.kill
workspace.active     workspace.created    workspace.removed   workspace.move_to_monitor
monitor.added        monitor.removed      monitor.focused     monitor.layout_changed
layer.opened         layer.closed
keybinds.submap      screenshare.state
```

Callbacks receive event-specific arguments. Check stubs or wiki for payload shapes.

---

## 5. Idiomatic patterns

### Splitting config with `require()`

```lua
-- hyprland.lua
require("binds")      -- loads ~/.config/hypr/binds.lua
require("rules")
require("theme")
```

Each required file has access to the `hl` global and runs in the same Lua state.

### Workspace binds with a loop

```lua
local mainMod = "SUPER"
for i = 1, 10 do
    local key = i % 10   -- 10 → key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
```

### Autostart on `hyprland.start`

```lua
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("nm-applet")
end)
```

### Conditional logic in an event handler

```lua
hl.on("window.open", function(win)
    if win.class == "steam" then
        hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    end
end)
```

### Submaps (resize mode example)

```lua
hl.define_submap("resize", "ESCAPE", function()
    hl.bind("left",  hl.dsp.window.resize({ direction = "left",  delta = 30 }), { repeating = true })
    hl.bind("right", hl.dsp.window.resize({ direction = "right", delta = 30 }), { repeating = true })
    hl.bind("up",    hl.dsp.window.resize({ direction = "up",    delta = 30 }), { repeating = true })
    hl.bind("down",  hl.dsp.window.resize({ direction = "down",  delta = 30 }), { repeating = true })
end)
hl.bind("SUPER + R", hl.dsp.submap("resize"))
```

### Gradient colors

```lua
hl.config({
    general = {
        col = {
            active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
    },
})
```

### Animation curves

```lua
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 6, bezier = "myBezier" })
```

### Mouse binds

```lua
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
```

### Stored handles

```lua
local closeRule = hl.window_rule({ name = "suppress-max", match = { class = ".*" }, suppress_event = "maximize" })
-- later, disable it:
closeRule:set_enabled(false)

local volUpBind = hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
```

---

## 6. hl.bind() options (`HL.BindOptions`)

| Option | Type | Meaning |
|--------|------|---------|
| `repeating` | bool | Fire repeatedly while held |
| `locked` | bool | Active even on lockscreen |
| `release` | bool | Fire on key release |
| `non_consuming` | bool | Don't consume the key event |
| `transparent` | bool | Pass to app even if matched |
| `mouse` | bool | Required for mouse button binds |
| `long_press` | bool | Fire after long press |
| `description`/`desc` | string | For bind listing tools |
| `device` | table | `{ list = {"device-name"}, inclusive = true }` |

---

## 7. `hyprctl dispatch` syntax in Hyprland 0.55+

The old keyword-based dispatcher syntax is **gone**. All dispatchers must use the Lua `hl.dsp.*` form.

### From the CLI / shell scripts

```bash
# WRONG — old syntax, will fail
hyprctl dispatch dpms toggle
hyprctl dispatch exec kitty
hyprctl dispatch workspace 3

# CORRECT — wrap the Lua dispatcher in single quotes
hyprctl dispatch 'hl.dsp.dpms("toggle")'
hyprctl dispatch 'hl.dsp.exec_cmd("kitty")'
hyprctl dispatch 'hl.dsp.focus({ workspace = 3 })'
hyprctl dispatch 'hl.dsp.window.float({ action = "toggle" })'
hyprctl dispatch 'hl.dsp.window.close()'
```

The string passed to `hyprctl dispatch` is evaluated as a Lua expression that must return an `HL.Dispatcher` value.

### From Lua code (`hl.dispatch`)

```lua
-- WRONG — do not pass a hyprctl shell string
hl.dispatch("hyprctl dispatch dpms toggle")

-- CORRECT — pass the hl.dsp.* dispatcher directly
hl.dispatch(hl.dsp.dpms("toggle"))
hl.dispatch(hl.dsp.exec_cmd("kitty"))
hl.dispatch(hl.dsp.focus({ workspace = 3 }))
```

`hl.dispatch()` takes an `HL.Dispatcher` object, not a string. Calling `hl.dsp.dpms("toggle")` produces that object.

---

## 8. Best practices

**Error isolation:** Wrap each `require()` call's contents in pcall if you want one bad module to not block the rest from loading. A top-level Lua error in the main file will prevent the whole config from applying.

**Emergency binds — always keep these, preferably near the top:**

```lua
local mainMod = "SUPER"
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("kitty"))   -- terminal escape hatch
hl.bind(mainMod .. " + M", hl.dsp.exit())              -- quit if stuck
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("hyprctl reload"))  -- reload
```

**Runtime errors vs. parse errors:**
- A Lua syntax error or top-level runtime error stops execution at that point; rules/binds defined before the error are kept.
- Errors inside event callbacks are isolated — one bad callback won't crash others.
- Use `hl.notification.create()` for in-session debug messages.

**`hl.exec_cmd` vs `hl.dsp.exec_cmd`:**
- `hl.exec_cmd("cmd")` — runs immediately, used in event handlers and startup.
- `hl.dsp.exec_cmd("cmd")` — creates a dispatcher value, used as argument to `hl.bind()`.

**Config ordering:** `hl.config()` calls merge; you can call it multiple times. Later calls override earlier ones for conflicting keys.

**Checking exact API on the running system:**

```bash
cat /usr/share/hypr/stubs/hl.meta.lua   # full typed stubs
```

Any option name not confirmed there or in the wiki should be treated as uncertain.
