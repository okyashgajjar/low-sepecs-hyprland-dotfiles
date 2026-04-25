#!/usr/bin/env bash

# ──────────────────────────────────────────────
#   Random Theme Switcher
# ──────────────────────────────────────────────

WALL_DIR="$HOME/wallpapers"
SCRIPT="$HOME/.config/hypr/scripts/swww-all.sh"

# Select a random image from the wallpapers directory
SELECTED_WALL=$(find "$WALL_DIR" -type f -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" | shuf -n 1)

if [ -n "$SELECTED_WALL" ]; then
    "$SCRIPT" "$SELECTED_WALL"
else
    notify-send "Wallpaper Error" "No images found in $WALL_DIR" -u critical
fi
