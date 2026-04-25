#!/usr/bin/env bash
# ──────────────────────────────────────────────
#   Power / Controls Menu for Waybar
# ──────────────────────────────────────────────

THEME="$HOME/.config/rofi/power-menu.rasi"
DIVIDER="────────────────────────────"

# ── Build menu ───────────────────────────────
build_menu() {
    echo "󰌾  Lock"
    echo "󰍃  Logout"
    echo "󰤄  Suspend"
    echo "󰜉  Reboot"
    echo "󰐥  Shutdown"
}

# ── Confirm dangerous action ─────────────────
confirm_action() {
    local action="$1"
    local choice
    choice=$(printf "  Yes, %s\n󰅙  Cancel" "$action" \
        | rofi -dmenu -p "  Confirm?" -theme "$THEME" -i)

    [[ "$choice" == *"Yes"* ]] && return 0 || return 1
}

# ── Handle selection ─────────────────────────
handle_selection() {
    local choice="$1"

    case "$choice" in
        "󰌾  Lock")
            hyprlock & ;;

        "󰍃  Logout")
            if confirm_action "logout"; then
                hyprctl dispatch exit
            fi ;;

        "󰤄  Suspend")
            if confirm_action "suspend"; then
                systemctl suspend
            fi ;;

        "󰜉  Reboot")
            if confirm_action "reboot"; then
                systemctl reboot
            fi ;;

        "󰐥  Shutdown")
            if confirm_action "shutdown"; then
                systemctl poweroff
            fi ;;
    esac
}

# ── Main ─────────────────────────────────────
main() {
    local menu
    menu=$(build_menu)

    local choice
    choice=$(echo "$menu" | rofi -dmenu -p "  Controls" -theme "$THEME" -i)

    [[ -z "$choice" ]] && exit 0

    handle_selection "$choice"
}

main
