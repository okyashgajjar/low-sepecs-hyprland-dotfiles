#!/usr/bin/env bash

# ──────────────────────────────────────────────
#   Global Theme Selector — Hyprland
#   Switches: Hyprland decor, Waybar, Rofi,
#   Script themes, and wallpaper set.
# ──────────────────────────────────────────────

WALL_DIR="$HOME/wallpapers"
SWWW_SCRIPT="$HOME/.config/hypr/scripts/swww-all.sh"
ACTIVE_THEME_FILE="$HOME/.config/hypr/.active-theme"

# Read current theme for display
CURRENT=$(cat "$ACTIVE_THEME_FILE" 2>/dev/null || echo "unknown")

THEMES=("󰏘  Material" "󰉺  Retro" "󰔉  Modern" "󰂫  Glass")
CHOICE=$(printf "%s\n" "${THEMES[@]}" | rofi -dmenu -i -p "  Theme [$CURRENT]" -theme ~/.config/rofi/theme.rasi)

[ -z "$CHOICE" ] && exit 0

# Extract theme name (strip icon prefix)
THEME_NAME=$(echo "$CHOICE" | sed 's/^[^ ]* *//')

case "$THEME_NAME" in
    "Material")
        HYPR_THEME="material"
        WAYBAR_THEME="floating-bar"
        ROFI_LAUNCHER="themes/material/launcher.rasi"
        ROFI_SCRIPTS="themes/material/scripts.rasi"
        WALL_SUBDIR="material"
        ;;
    "Retro")
        HYPR_THEME="retro"
        WAYBAR_THEME="retro-left"
        ROFI_LAUNCHER="themes/retro/launcher.rasi"
        ROFI_SCRIPTS="themes/retro/scripts.rasi"
        WALL_SUBDIR="retro"
        ;;
    "Modern")
        HYPR_THEME="modern"
        WAYBAR_THEME="bottom-dock"
        ROFI_LAUNCHER="themes/modern/launcher.rasi"
        ROFI_SCRIPTS="themes/modern/scripts.rasi"
        WALL_SUBDIR="modern"
        ;;
    "Glass")
        HYPR_THEME="glass"
        WAYBAR_THEME="glass-right"
        ROFI_LAUNCHER="themes/glass/launcher.rasi"
        ROFI_SCRIPTS="themes/glass/scripts.rasi"
        WALL_SUBDIR="glass"
        ;;
    *) exit 0 ;;
esac

# ── 1. Hyprland Theme ──
ln -sf "$HOME/.config/hypr/themes/$HYPR_THEME/theme.conf" "$HOME/.config/hypr/theme.conf"

# ── 2. Waybar Theme ──
ln -sf "$HOME/.config/waybar/themes/$WAYBAR_THEME/config.jsonc" "$HOME/.config/waybar/config.jsonc"
ln -sf "$HOME/.config/waybar/themes/$WAYBAR_THEME/style.css" "$HOME/.config/waybar/style.css"

# ── 3. Rofi Themes (Launcher + Scripts) ──
ln -sf "$HOME/.config/rofi/$ROFI_LAUNCHER" "$HOME/.config/rofi/active-launcher.rasi"
ln -sf "$HOME/.config/rofi/$ROFI_SCRIPTS" "$HOME/.config/rofi/active-scripts.rasi"

# ── 4. Save active theme ──
echo "$THEME_NAME" > "$ACTIVE_THEME_FILE"

# ── 5. Reload Hyprland ──
hyprctl reload

# ── 6. Restart Waybar ──
killall waybar 2>/dev/null
sleep 0.3
waybar & disown

# ── 7. Set a random wallpaper from the theme's set ──
SELECTED_WALL=$(find "$WALL_DIR/$WALL_SUBDIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) 2>/dev/null | shuf -n 1)
if [ -n "$SELECTED_WALL" ]; then
    "$SWWW_SCRIPT" "$SELECTED_WALL"
fi

notify-send "  Theme: $THEME_NAME" "Waybar · Rofi · Hyprland · Wallpaper updated" -i preferences-desktop-theme
