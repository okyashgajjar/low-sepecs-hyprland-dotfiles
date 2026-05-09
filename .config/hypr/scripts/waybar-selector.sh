#!/usr/bin/env bash
# ──────────────────────────────────────────────
#   Waybar Style Selector
# ──────────────────────────────────────────────

WAYBAR_THEMES_DIR="$HOME/.config/waybar/themes"
ACTIVE_THEME_FILE="$HOME/.config/hypr/.active-theme"

# 1. List available styles
CHOICE=$(ls "$WAYBAR_THEMES_DIR" | sort | rofi -dmenu -i -p "  Waybar Style" -theme ~/.config/rofi/active-scripts.rasi)

[ -z "$CHOICE" ] && exit 0

# 2. Apply the selected waybar style
ln -sf "$WAYBAR_THEMES_DIR/$CHOICE/config.jsonc" "$HOME/.config/waybar/config.jsonc"
ln -sf "$WAYBAR_THEMES_DIR/$CHOICE/style.css" "$HOME/.config/waybar/style.css"

# 3. Restart Waybar
killall waybar 2>/dev/null
sleep 0.3
waybar & disown

notify-send "  Waybar Updated" "Style: $CHOICE applied" -i preferences-desktop-theme
