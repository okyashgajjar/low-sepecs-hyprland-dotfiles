#!/usr/bin/env bash

# ── Global Theme Selector ──

THEMES=("Material" "Retro" "Modern" "Glass")
CHOICE=$(printf "%s\n" "${THEMES[@]}" | rofi -dmenu -i -p "Select Global Theme" -theme ~/.config/rofi/theme.rasi)

if [ -z "$CHOICE" ]; then
    exit 0
fi

case "$CHOICE" in
    "Material")
        HYPR_THEME="material"
        WAYBAR_THEME="floating-bar"
        ROFI_LINK="material-dashboard.rasi"
        ;;
    "Retro")
        HYPR_THEME="retro"
        WAYBAR_THEME="retro-left"
        ROFI_LINK="themes/retro.rasi"
        ;;
    "Modern")
        HYPR_THEME="modern"
        WAYBAR_THEME="bottom-dock"
        ROFI_LINK="theme.rasi"
        ;;
    "Glass")
        HYPR_THEME="glass"
        WAYBAR_THEME="glass-right"
        ROFI_LINK="themes/glass.rasi"
        ;;
esac

# 1. Update Hyprland Theme
ln -sf ~/.config/hypr/themes/$HYPR_THEME/theme.conf ~/.config/hypr/theme.conf
hyprctl reload

# 2. Update Waybar Theme
ln -sf ~/.config/waybar/themes/$WAYBAR_THEME/config.jsonc ~/.config/waybar/config.jsonc
# Ensure style.css also exists for all themes
if [ -f ~/.config/waybar/themes/$WAYBAR_THEME/style.css ]; then
    ln -sf ~/.config/waybar/themes/$WAYBAR_THEME/style.css ~/.config/waybar/style.css
fi

killall waybar; waybar & disown

# 3. Update Rofi Theme (Main)
# (Optional: link actual theme files if needed)

notify-send "Global Theme Applied" "Switched to $CHOICE theme" -i preferences-desktop-theme
