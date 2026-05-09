#!/usr/bin/env bash
# ──────────────────────────────────────────────
#   Theme-Aware Wallpaper Selector
# ──────────────────────────────────────────────

WALL_DIR="$HOME/wallpapers"
ACTIVE_THEME_FILE="$HOME/.config/hypr/.active-theme"
SWWW_SCRIPT="$HOME/.config/hypr/scripts/swww-all.sh"

# 1. Determine active theme subdirectory
THEME=$(cat "$ACTIVE_THEME_FILE" 2>/dev/null || echo "material")
# Lowercase the theme name for folder matching
THEME_DIR=$(echo "$THEME" | tr '[:upper:]' '[:lower:]')

# Fallback to root wallpapers if theme dir missing
[ ! -d "$WALL_DIR/$THEME_DIR" ] && THEME_DIR="."

# 2. List wallpapers with Rofi
CHOICE=$(find "$WALL_DIR/$THEME_DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) -printf "%f\n" | sort | rofi -dmenu -i -p "  Wallpaper [$THEME]" -theme ~/.config/rofi/active-scripts.rasi)

[ -z "$CHOICE" ] && exit 0

# 3. Apply the selected wallpaper
"$SWWW_SCRIPT" "$WALL_DIR/$THEME_DIR/$CHOICE"
