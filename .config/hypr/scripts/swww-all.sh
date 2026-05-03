#!/usr/bin/env bash

# ──────────────────────────────────────────────
#   Dynamic Theme Switcher (Awww + Matugen)
# ──────────────────────────────────────────────

WALLPAPER="$1"

if [ -z "$WALLPAPER" ]; then
    echo "Usage: ./swww-all.sh /path/to/wallpaper.jpg"
    exit 1
fi

# 1. Set Wallpaper
# Using awww-daemon
awww img "$WALLPAPER" --transition-type grow --transition-pos "$(hyprctl cursorpos)" --transition-duration 1.5

# 2. Extract colors with Matugen
# This updates colors for Waybar, Rofi, Kitty, Hyprland, etc.
matugen image "$WALLPAPER" -c ~/.config/matugen/config.toml --source-color-index 0

# 3. Reload Waybar
# SIGUSR2 tells waybar to reload its CSS
killall -SIGUSR2 waybar

# 4. Reload Kitty
# SIGUSR1 tells kitty to reload its configuration
killall -SIGUSR1 kitty

# 5. Reload Hyprland
# Sending a SIGUSR1 to hyprland often forces a reload of sourced files
# or we can use hyprctl reload
hyprctl reload

# 6. Reload Neovim
# SIGUSR1 tells nvim to reload colors
killall -SIGUSR1 nvim 2>/dev/null

# 7. Notify
notify-send "Theme Updated" "Colors extracted from $(basename "$WALLPAPER")" -i "$WALLPAPER"
