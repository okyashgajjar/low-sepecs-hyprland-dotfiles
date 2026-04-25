#!/usr/bin/env bash

# ──────────────────────────────────────────────
#   Dynamic Theme Switcher
# ──────────────────────────────────────────────

WALLPAPER="$1"

if [ -z "$WALLPAPER" ]; then
    echo "Usage: ./swww-all.sh /path/to/wallpaper.jpg"
    exit 1
fi

# 1. Set Wallpaper
awww img "$WALLPAPER" --transition-type grow --transition-pos "$(hyprctl cursorpos)" --transition-duration 1.5

# 2. Extract colors with Matugen
matugen image "$WALLPAPER" -c ~/.config/matugen/config.toml --source-color-index 0

# 3. Reload Waybar
killall -SIGUSR2 waybar

# 4. Reload Kitty
# (Matugen post_hook could handle this, but we'll do it explicitly if needed)
# killall -SIGUSR1 kitty

# 5. Reload Rofi
# (No reload needed, it reads config on start)

# 6. Reload Pywalfox
# pywalfox update

# 7. Notify
notify-send "Theme Updated" "Colors extracted from $(basename "$WALLPAPER")" -i "$WALLPAPER"
