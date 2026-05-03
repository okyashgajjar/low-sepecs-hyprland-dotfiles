#!/usr/bin/env bash
# ──────────────────────────────────────────────
#   Bluetooth Menu for Waybar (rofi + bluetoothctl)
# ──────────────────────────────────────────────

# Use active theme script style
THEME="$HOME/.config/rofi/active-scripts.rasi"
# Fallback if symlink missing
[ ! -f "$THEME" ] && THEME="$HOME/.config/rofi/material-scripts.rasi"
DIVIDER="────────────────────────────"

# Handle positioning
POSITION="$1"
ROFI_ARGS=""
if [[ "$POSITION" == "left" ]]; then
    ROFI_ARGS="-location 7 -xoffset 60 -yoffset -20"
fi

notify() {
    notify-send -a "Bluetooth" -i bluetooth "$1" "$2" -t 4000
}

# ── Get bluetooth state ──────────────────────
get_state() {
    BT_POWERED=$(bluetoothctl show 2>/dev/null | grep -i "Powered:" | awk '{print $2}')
    BT_SCANNING=$(bluetoothctl show 2>/dev/null | grep -i "Discovering:" | awk '{print $2}')
}

# ── Get connected devices ────────────────────
get_connected() {
    bluetoothctl devices Connected 2>/dev/null | cut -d' ' -f3-
}

# ── Get paired devices ───────────────────────
get_paired() {
    bluetoothctl devices Paired 2>/dev/null
}

# ── Build main menu ──────────────────────────
build_menu() {
    get_state

    if [[ "$BT_POWERED" != "yes" ]]; then
        echo "󰂲  Bluetooth is OFF"
        echo "$DIVIDER"
        echo "󰂯  Turn Bluetooth ON"
        return
    fi

    # Status header
    local connected
    connected=$(get_connected)
    if [[ -n "$connected" ]]; then
        echo "󰂱  Connected: $connected"
    else
        echo "󰂯  Bluetooth ON — no devices"
    fi
    echo "$DIVIDER"

    echo "󰑐  Scan for devices"
    echo "$DIVIDER"

    # Paired devices
    local has_paired=false
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local mac name
        mac=$(echo "$line" | awk '{print $2}')
        name=$(echo "$line" | cut -d' ' -f3-)
        [[ -z "$name" ]] && name="$mac"

        # Check if connected
        local info
        info=$(bluetoothctl info "$mac" 2>/dev/null)
        local is_connected
        is_connected=$(echo "$info" | grep -i "Connected:" | awk '{print $2}')
        local icon_type
        icon_type=$(echo "$info" | grep -i "Icon:" | awk '{print $2}')

        # Pick icon based on type
        local icon="󰂱"
        case "$icon_type" in
            audio*|headset|headphones) icon="󰋋" ;;
            input-keyboard)           icon="󰌌" ;;
            input-mouse)              icon="󰍽" ;;
            input-gaming)             icon="󰊗" ;;
            phone)                    icon="󰏲" ;;
            computer)                 icon="󰍹" ;;
        esac

        if [[ "$is_connected" == "yes" ]]; then
            echo "$icon  $name  ✓"
        else
            echo "$icon  $name"
        fi
        has_paired=true
    done < <(get_paired)

    # Scanned (not paired) devices
    if [[ "$BT_SCANNING" == "yes" ]]; then
        local scan_results
        scan_results=$(bluetoothctl devices 2>/dev/null)
        local paired_macs
        paired_macs=$(get_paired | awk '{print $2}')

        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            local mac name
            mac=$(echo "$line" | awk '{print $2}')
            name=$(echo "$line" | cut -d' ' -f3-)

            # Skip already paired
            echo "$paired_macs" | grep -q "$mac" && continue
            # Skip unnamed/address-only devices
            [[ "$name" == "$mac" ]] && continue

            echo "󰂳  $name"
        done <<< "$scan_results"
    fi

    echo "$DIVIDER"

    # Bottom actions
    if [[ -n "$connected" ]]; then
        echo "󰂲  Disconnect all"
    fi
    echo "󰂲  Turn Bluetooth OFF"
}

# ── Handle selection ─────────────────────────
handle_selection() {
    local choice="$1"

    case "$choice" in
        "󰂱  Connected:"*|"󰂯  Bluetooth ON"*|"󰂲  Bluetooth is OFF"|"$DIVIDER")
            return ;;

        "󰂯  Turn Bluetooth ON")
            bluetoothctl power on 2>/dev/null
            notify "Bluetooth ON" "Bluetooth radio enabled"
            sleep 1
            main ;;

        "󰂲  Turn Bluetooth OFF")
            bluetoothctl power off 2>/dev/null
            notify "Bluetooth OFF" "Bluetooth radio disabled" ;;

        "󰑐  Scan for devices")
            notify "Scanning…" "Looking for nearby devices"
            bluetoothctl --timeout 8 scan on 2>/dev/null &
            sleep 5
            main ;;

        "󰂲  Disconnect all")
            while IFS= read -r line; do
                [[ -z "$line" ]] && continue
                local mac
                mac=$(echo "$line" | awk '{print $2}')
                bluetoothctl disconnect "$mac" 2>/dev/null
            done < <(bluetoothctl devices Connected 2>/dev/null)
            notify "Disconnected" "All devices disconnected" ;;

        *)
            # Device selected — extract name
            local name
            name=$(echo "$choice" | sed 's/^[^ ]* *//' | sed 's/  ✓$//')

            if [[ -z "$name" ]]; then
                return
            fi

            # Find MAC by name
            local mac
            mac=$(bluetoothctl devices 2>/dev/null | grep "$name" | head -1 | awk '{print $2}')

            if [[ -z "$mac" ]]; then
                notify "Error" "Could not find device: $name"
                return
            fi

            # Check current state
            local info is_connected is_paired
            info=$(bluetoothctl info "$mac" 2>/dev/null)
            is_connected=$(echo "$info" | grep -i "Connected:" | awk '{print $2}')
            is_paired=$(echo "$info" | grep -i "Paired:" | awk '{print $2}')

            if [[ "$is_connected" == "yes" ]]; then
                # Show device submenu
                local action
                action=$(printf "%s\n%s\n%s" \
                    "󰅙  Disconnect" \
                    "󰆴  Remove (unpair)" \
                    "⬅  Back" \
                    | rofi -dmenu $ROFI_ARGS -p "  $name" -theme "$THEME" -i)

                case "$action" in
                    "󰅙  Disconnect")
                        bluetoothctl disconnect "$mac" 2>/dev/null
                        notify "Disconnected" "$name disconnected" ;;
                    "󰆴  Remove (unpair)")
                        bluetoothctl remove "$mac" 2>/dev/null
                        notify "Removed" "$name has been unpaired" ;;
                    "⬅  Back")
                        main ;;
                esac
            elif [[ "$is_paired" == "yes" ]]; then
                # Paired but not connected — connect or remove
                local action
                action=$(printf "%s\n%s\n%s" \
                    "󰂱  Connect" \
                    "󰆴  Remove (unpair)" \
                    "⬅  Back" \
                    | rofi -dmenu $ROFI_ARGS -p "  $name" -theme "$THEME" -i)

                case "$action" in
                    "󰂱  Connect")
                        notify "Connecting…" "Connecting to $name"
                        if bluetoothctl connect "$mac" 2>/dev/null; then
                            sleep 2
                            local check
                            check=$(bluetoothctl info "$mac" 2>/dev/null | grep "Connected:" | awk '{print $2}')
                            if [[ "$check" == "yes" ]]; then
                                notify "Connected ✓" "Successfully connected to $name"
                            else
                                notify "Failed ✗" "Could not connect to $name"
                            fi
                        else
                            notify "Failed ✗" "Could not connect to $name"
                        fi ;;
                    "󰆴  Remove (unpair)")
                        bluetoothctl remove "$mac" 2>/dev/null
                        notify "Removed" "$name has been unpaired" ;;
                    "⬅  Back")
                        main ;;
                esac
            else
                # New device — pair first
                notify "Pairing…" "Pairing with $name"
                bluetoothctl pair "$mac" 2>/dev/null
                sleep 3
                local pair_check
                pair_check=$(bluetoothctl info "$mac" 2>/dev/null | grep "Paired:" | awk '{print $2}')
                if [[ "$pair_check" == "yes" ]]; then
                    bluetoothctl trust "$mac" 2>/dev/null
                    notify "Connecting…" "Paired! Connecting to $name"
                    bluetoothctl connect "$mac" 2>/dev/null
                    sleep 2
                    local conn_check
                    conn_check=$(bluetoothctl info "$mac" 2>/dev/null | grep "Connected:" | awk '{print $2}')
                    if [[ "$conn_check" == "yes" ]]; then
                        notify "Connected ✓" "Successfully connected to $name"
                    else
                        notify "Paired ✓" "Paired but couldn't auto-connect to $name"
                    fi
                else
                    notify "Failed ✗" "Could not pair with $name"
                fi
            fi
            ;;
    esac
}

# ── Main ─────────────────────────────────────
main() {
    local menu
    menu=$(build_menu)

    local choice
    choice=$(echo "$menu" | rofi -dmenu $ROFI_ARGS -p "󰂯  Bluetooth" -theme "$THEME" -i)

    [[ -z "$choice" ]] && exit 0

    handle_selection "$choice"
}

main
