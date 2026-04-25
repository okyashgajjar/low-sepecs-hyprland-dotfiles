#!/usr/bin/env bash

# Check for updates
PACMAN_UPDATES=$(checkupdates 2>/dev/null)
AUR_UPDATES=$(yay -Qua 2>/dev/null)

PACMAN_COUNT=$(echo "$PACMAN_UPDATES" | grep -c '[^[:space:]]')
AUR_COUNT=$(echo "$AUR_UPDATES" | grep -c '[^[:space:]]')

TOTAL_COUNT=$((PACMAN_COUNT + AUR_COUNT))

if [ "$TOTAL_COUNT" -gt 0 ]; then
    # Format tooltip with the list of updates
    TOOLTIP="Pacman Updates ($PACMAN_COUNT):\n$PACMAN_UPDATES\n\nAUR Updates ($AUR_COUNT):\n$AUR_UPDATES"
    
    # Output JSON for Waybar
    echo "{\"text\": \"$TOTAL_COUNT\", \"tooltip\": \"$TOOLTIP\", \"class\": \"updates-available\"}"
else
    # Output nothing to hide the module
    echo ""
fi
