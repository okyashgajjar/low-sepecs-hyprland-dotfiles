#!/usr/bin/env bash
# ──────────────────────────────────────────────
#   Enhanced Theme & Style Selector
# ──────────────────────────────────────────────

WALL_DIR="$HOME/wallpapers"
SWWW_SCRIPT="$HOME/.config/hypr/scripts/swww-all.sh"
ACTIVE_THEME_FILE="$HOME/.config/hypr/.active-theme"
CURRENT=$(cat "$ACTIVE_THEME_FILE" 2>/dev/null || echo "unknown")

# --- Define the Menu ---
MENU="󰏘  Material\n󰉺  Retro\n󰔉  Modern\n󰂫  Glass\n󰘵  Noro\n────────────────────\n󰃟  Change Wallpaper\n󰕮  Change Waybar Style"

CHOICE=$(echo -e "$MENU" | rofi -dmenu -i -p "  Theme [$CURRENT]" -theme ~/.config/rofi/active-scripts.rasi)

[ -z "$CHOICE" ] || [[ "$CHOICE" == "───"* ]] && exit 0

case "$CHOICE" in
    *"Change Wallpaper"*)
        ~/.config/hypr/scripts/wall-selector.sh
        exit 0 ;;
    *"Change Waybar Style"*)
        ~/.config/hypr/scripts/waybar-selector.sh
        exit 0 ;;
    *"Material"*) THEME="Material"; HYPR="material"; WAYBAR="floating-bar"; WALL="material" ;;
    *"Retro"*)    THEME="Retro";    HYPR="retro";    WAYBAR="retro-left";   WALL="retro" ;;
    *"Modern"*)   THEME="Modern";   HYPR="modern";   WAYBAR="bottom-dock";  WALL="modern" ;;
    *"Glass"*)    THEME="Glass";    HYPR="glass";    WAYBAR="glass-right";  WALL="glass" ;;
    *"Noro"*)     THEME="Noro";     HYPR="noro";     WAYBAR="noro";         WALL="noro" ;;
    *) exit 0 ;;
esac

# ── 1. Apply Selections ──
ln -sf "$HOME/.config/hypr/themes/$HYPR/theme.conf" "$HOME/.config/hypr/theme.conf"
ln -sf "$HOME/.config/waybar/themes/$WAYBAR/config.jsonc" "$HOME/.config/waybar/config.jsonc"
ln -sf "$HOME/.config/waybar/themes/$WAYBAR/style.css" "$HOME/.config/waybar/style.css"
ln -sf "$HOME/.config/rofi/themes/$HYPR/launcher.rasi" "$HOME/.config/rofi/active-launcher.rasi"
ln -sf "$HOME/.config/rofi/themes/$HYPR/scripts.rasi" "$HOME/.config/rofi/active-scripts.rasi"

# ── 2. Save active theme ──
echo "$THEME" > "$ACTIVE_THEME_FILE"

# ── 3. Apply Wallpaper (Random from theme set) ──
SELECTED_WALL=$(find "$WALL_DIR/$WALL" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) 2>/dev/null | shuf -n 1)
[ -n "$SELECTED_WALL" ] && "$SWWW_SCRIPT" "$SELECTED_WALL"

# ── 4. Reload ──
hyprctl reload
killall waybar 2>/dev/null
waybar & disown

notify-send "  Theme: $THEME" "Full system aesthetic updated" -i preferences-desktop-theme
