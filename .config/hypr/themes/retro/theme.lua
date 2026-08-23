-- ── Retro Theme — Lua (0.55+) ──
-- Mirrors themes/retro/theme.conf · generated port
-- Expects colors.lua to be loaded (provides active_border / inactive_border)
-- Safe to `pcall(require, "colors")` if needed.

local colors = nil
pcall(function() colors = require("colors") end)
local ab = (colors and colors.active_border) or (type(active_border) == "string" and active_border) or "85d6c1"
local ib = (colors and colors.inactive_border) or (type(inactive_border) == "string" and inactive_border) or "3f4946"

hl.config({
    decoration = {
    rounding = 0,
    blur = { enabled = false },
    shadow = { enabled = false },
    },
    general = {
        gaps_in = 3,
        gaps_out = 6,
        border_size = 2,
        col = {
            active_border = "rgb(" .. ab .. ")",
            inactive_border = "rgb(" .. ib .. ")",
        },
        layout = "dwindle",
        allow_tearing = false,
    },
})
