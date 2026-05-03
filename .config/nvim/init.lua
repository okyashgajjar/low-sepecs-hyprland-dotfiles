-- ─────────────────────────────────────────────
--   Neovim Config — Material You Dynamic Colors
-- ─────────────────────────────────────────────

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"

-- ── Apply Matugen colors ──
local function apply_matugen_colors()
    local ok, colors = pcall(require, "matugen-colors")
    if not ok then return end

    local c = colors.colors
    local hi = vim.api.nvim_set_hl

    -- Core UI
    hi(0, "Normal",       { fg = c.fg, bg = c.bg })
    hi(0, "NormalFloat",  { fg = c.fg, bg = c.surface })
    hi(0, "CursorLine",   { bg = c.surface })
    hi(0, "Visual",       { bg = c.primary, fg = c.on_primary })
    hi(0, "Search",       { bg = c.tertiary, fg = c.bg })
    hi(0, "IncSearch",    { bg = c.primary, fg = c.on_primary })

    -- Line numbers
    hi(0, "LineNr",       { fg = c.outline })
    hi(0, "CursorLineNr", { fg = c.primary, bold = true })

    -- Statusline
    hi(0, "StatusLine",   { fg = c.fg, bg = c.surface })
    hi(0, "StatusLineNC", { fg = c.outline, bg = c.bg })

    -- Popups & menus
    hi(0, "Pmenu",        { fg = c.fg, bg = c.surface })
    hi(0, "PmenuSel",     { fg = c.on_primary, bg = c.primary })
    hi(0, "PmenuThumb",   { bg = c.primary })

    -- Syntax
    hi(0, "Comment",      { fg = c.outline, italic = true })
    hi(0, "Constant",     { fg = c.tertiary })
    hi(0, "String",       { fg = c.secondary })
    hi(0, "Identifier",   { fg = c.fg })
    hi(0, "Function",     { fg = c.primary })
    hi(0, "Statement",    { fg = c.primary, bold = true })
    hi(0, "Keyword",      { fg = c.primary })
    hi(0, "Type",         { fg = c.tertiary })
    hi(0, "Special",      { fg = c.secondary })
    hi(0, "Error",        { fg = c.error })
    hi(0, "Todo",         { fg = c.on_primary, bg = c.primary, bold = true })

    -- Diagnostics
    hi(0, "DiagnosticError", { fg = c.error })
    hi(0, "DiagnosticWarn",  { fg = c.tertiary })
    hi(0, "DiagnosticInfo",  { fg = c.primary })
    hi(0, "DiagnosticHint",  { fg = c.secondary })

    -- Diff
    hi(0, "DiffAdd",      { bg = c.primary, fg = c.on_primary })
    hi(0, "DiffChange",   { bg = c.secondary, fg = c.on_secondary })
    hi(0, "DiffDelete",   { bg = c.error, fg = c.bg })
end

apply_matugen_colors()

-- Auto-reload colors when the file changes (wallpaper switch)
vim.api.nvim_create_autocmd("Signal", {
    pattern = "SIGUSR1",
    callback = function()
        package.loaded["matugen-colors"] = nil
        apply_matugen_colors()
    end,
})
