#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/wallpapers"

# Check if directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Error" "Wallpaper directory not found"
    exit 1
fi

# List images, pass to rofi, and get selection
SELECTED=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) -exec basename {} \; | rofi -dmenu -i -p "Select Wallpaper" -theme ~/.config/rofi/theme.rasi)

if [ -n "$SELECTED" ]; then
    FULL_PATH="$WALLPAPER_DIR/$SELECTED"
    # Call the existing swww-all.sh script
    ~/.config/hypr/scripts/swww-all.sh "$FULL_PATH"
fi
