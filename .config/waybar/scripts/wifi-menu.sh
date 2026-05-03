#!/usr/bin/env bash
# ──────────────────────────────────────────────
#   WiFi Menu for Waybar (rofi + nmcli)
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
    notify-send -a "WiFi Menu" -i network-wireless "$1" "$2" -t 4000
}

# ── Get current connection info ──────────────
get_status() {
    WIFI_STATE=$(nmcli radio wifi)
    if [[ "$WIFI_STATE" == "enabled" ]]; then
        CURRENT_SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)
        CURRENT_IP=$(nmcli -t -f IP4.ADDRESS dev show 2>/dev/null | head -1 | cut -d':' -f2)
        SIGNAL=$(nmcli -t -f active,signal dev wifi | grep '^yes' | cut -d':' -f2)
    fi
}

# ── Build the menu ───────────────────────────
build_menu() {
    get_status

    # Header actions
    if [[ "$WIFI_STATE" == "enabled" ]]; then
        if [[ -n "$CURRENT_SSID" ]]; then
            echo "󰤨  Connected: $CURRENT_SSID (${SIGNAL}%)"
        else
            echo "󰤭  Not connected"
        fi
        echo "$DIVIDER"
        echo "󰑐  Rescan networks"
        echo "$DIVIDER"

        # List available networks (deduplicated, sorted by signal)
        nmcli -t -f SSID,SIGNAL,SECURITY,IN-USE dev wifi list --rescan no 2>/dev/null \
            | awk -F: '!seen[$1]++ && $1 != "" {
                icon = "󰤟 "
                if ($2 > 25) icon = "󰤢 "
                if ($2 > 50) icon = "󰤥 "
                if ($2 > 75) icon = "󰤨 "
                lock = ($3 != "" && $3 != "--") ? " 󰌾" : ""
                active = ($4 == "*") ? " ✓" : ""
                printf "%s %s  %s%%%s%s\n", icon, $1, $2, lock, active
            }'

        echo "$DIVIDER"

        # Bottom actions
        if [[ -n "$CURRENT_SSID" ]]; then
            echo "󰅙  Disconnect"
        fi
        echo "󱛅  Saved connections"
        echo "󰖪  Turn WiFi OFF"
    else
        echo "󰖪  WiFi is OFF"
        echo "$DIVIDER"
        echo "󰖩  Turn WiFi ON"
    fi
}

# ── Handle selection ─────────────────────────
handle_selection() {
    local choice="$1"

    case "$choice" in
        "󰤨  Connected:"*|"󰤭  Not connected"|"$DIVIDER")
            # Info/divider lines — do nothing
            return ;;

        "󰑐  Rescan networks")
            notify "Scanning…" "Looking for WiFi networks"
            nmcli dev wifi rescan 2>/dev/null
            sleep 2
            main
            return ;;

        "󰅙  Disconnect")
            nmcli dev disconnect wlan0 2>/dev/null || nmcli dev disconnect wlp0s20f3 2>/dev/null
            notify "Disconnected" "WiFi has been disconnected"
            return ;;

        "󰖪  Turn WiFi OFF")
            nmcli radio wifi off
            notify "WiFi OFF" "Wireless radio disabled"
            return ;;

        "󰖩  Turn WiFi ON")
            nmcli radio wifi on
            notify "WiFi ON" "Wireless radio enabled — scanning…"
            sleep 3
            main
            return ;;

        "󱛅  Saved connections")
            show_saved
            return ;;

        "󰖪  WiFi is OFF")
            return ;;

        *)
            # Network selected — extract SSID
            local ssid
            ssid=$(echo "$choice" | sed 's/^󰤟  \|^󰤢  \|^󰤥  \|^󰤨  //' | sed 's/  [0-9]*%.*$//')

            if [[ -z "$ssid" ]]; then
                return
            fi

            # Check if already connected
            get_status
            if [[ "$CURRENT_SSID" == "$ssid" ]]; then
                notify "Already connected" "You are already on $ssid"
                return
            fi

            # Check if we have a saved profile
            if nmcli -t -f NAME con show 2>/dev/null | grep -qx "$ssid"; then
                notify "Connecting…" "Connecting to $ssid"
                if nmcli con up "$ssid" 2>/dev/null; then
                    notify "Connected ✓" "Successfully connected to $ssid"
                else
                    notify "Failed ✗" "Could not connect to $ssid"
                fi
            else
                # Need password — prompt via rofi
                local security
                security=$(nmcli -t -f SSID,SECURITY dev wifi list --rescan no 2>/dev/null \
                    | grep "^${ssid}:" | head -1 | cut -d: -f2)

                if [[ -n "$security" && "$security" != "--" ]]; then
                    local pass
                    pass=$(rofi -dmenu $ROFI_ARGS -p "󰌾  Password" \
                        -theme "$THEME" \
                        -mesg "Enter password for <b>$ssid</b>" \
                        -password)

                    if [[ -z "$pass" ]]; then
                        return
                    fi

                    notify "Connecting…" "Connecting to $ssid"
                    if nmcli dev wifi connect "$ssid" password "$pass" 2>/dev/null; then
                        notify "Connected ✓" "Successfully connected to $ssid"
                    else
                        notify "Failed ✗" "Wrong password or connection failed"
                    fi
                else
                    # Open network
                    notify "Connecting…" "Connecting to $ssid"
                    if nmcli dev wifi connect "$ssid" 2>/dev/null; then
                        notify "Connected ✓" "Successfully connected to $ssid"
                    else
                        notify "Failed ✗" "Could not connect to $ssid"
                    fi
                fi
            fi
            ;;
    esac
}

# ── Saved connections submenu ────────────────
show_saved() {
    local saved_menu=""
    saved_menu+="⬅  Back\n"
    saved_menu+="$DIVIDER\n"

    while IFS= read -r conn; do
        [[ -n "$conn" ]] && saved_menu+="󰤨  $conn\n"
    done < <(nmcli -t -f NAME,TYPE con show | grep ':.*wireless' | cut -d: -f1)

    local choice
    choice=$(echo -e "$saved_menu" | rofi -dmenu $ROFI_ARGS -p "󱛅  Saved" -theme "$THEME" -i)

    [[ -z "$choice" ]] && return

    case "$choice" in
        "⬅  Back")
            main
            return ;;
        "$DIVIDER")
            show_saved
            return ;;
        *)
            local ssid="${choice#󰤨  }"
            local action
            action=$(echo -e "󰤨  Connect\n󰅙  Forget" \
                | rofi -dmenu $ROFI_ARGS -p "  $ssid" -theme "$THEME")

            case "$action" in
                "󰤨  Connect")
                    notify "Connecting…" "Connecting to $ssid"
                    if nmcli con up "$ssid" 2>/dev/null; then
                        notify "Connected ✓" "Successfully connected to $ssid"
                    else
                        notify "Failed ✗" "Could not connect to $ssid"
                    fi ;;
                "󰅙  Forget")
                    nmcli con delete "$ssid" 2>/dev/null
                    notify "Forgotten" "$ssid has been removed"
                    show_saved ;;
            esac
            ;;
    esac
}

# ── Main ─────────────────────────────────────
main() {
    local menu
    menu=$(build_menu)

    local choice
    choice=$(echo "$menu" | rofi -dmenu $ROFI_ARGS -p "󰖩  WiFi" -theme "$THEME" -i)

    [[ -z "$choice" ]] && exit 0

    handle_selection "$choice"
}

main
