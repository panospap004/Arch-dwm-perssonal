#!/usr/bin/env bash
# works 
# script name: dm-wifi
# Description: Connect to wifi using dmenu
# Dependencies: dmenu OR fzf OR rofi, nmcli, Any Nerd Font, ping

# The following OPTIONS are accepted:
#     -h  displays this help page
#     -d  runs the script using 'dmenu'
#     -f  runs the script using 'fzf'
#     -r  runs the script using 'rofi'
#     -g  opens GNOME Control Center

set -euo pipefail

# Configuration
DMENU="dmenu -i -l 20 -g 2 -p"
RMENU="rofi -i -dmenu -config ~/.config/rofi/config-compact.rasi -p"
FMENU="fzf --bind=enter:replace-query+print-query --border=rounded --margin=5% --color=dark --height 100% --reverse --header=$(basename "$0") --info=hidden --header-first --prompt"

# Helper functions
err() {
    printf 'Error: %s\n' "$1"
    exit 1
}

get_menu_program() {
    while getopts "dfrhg" arg 2>/dev/null; do
        case "${arg}" in
        d) echo "${DMENU}"; return 0 ;;
        f) echo "${FMENU}"; return 0 ;;
        r) echo "${RMENU}"; return 0 ;;
        h) help; return 1 ;;
        g) echo "gnome-control-center"; return 0 ;;
        *) echo "invalid option: Type $(basename "$0") -h for help" >/dev/stderr; return 1 ;;
        esac
    done
    echo "${DMENU}"
}

help() {
    printf '%s\n' "Usage: $(basename "$0") [options]
Description: Connect to wifi using dmenu
Dependencies: dmenu OR fzf OR rofi, nmcli, Any Nerd Font, ping

The following OPTIONS are accepted:
    -h  displays this help page
    -d  runs the script using 'dmenu'
    -f  runs the script using 'fzf'
    -r  runs the script using 'rofi'
    -g  opens GNOME Control Center

Running $(basename "$0") without any argument defaults to using 'dmenu'

Note: This script requires NetworkManager (nmcli) to manage WiFi connections."
}

main() {
    MENU="$(get_menu_program "$@")"
    if [[ "$MENU" == "gnome-control-center" ]]; then
        env XDG_CURRENT_DESKTOP=GNOME gnome-control-center &
        exit 0
    fi

    # Check dependencies
    if ! command -v nmcli >/dev/null 2>&1; then
        err "nmcli (NetworkManager) is required but not installed"
    fi

    if ! command -v ping >/dev/null 2>&1; then
        err "ping is required but not installed"
    fi

    # Get available WiFi networks
    bssid=$(nmcli device wifi list 2>/dev/null | sed -n '1!p' | cut -b 9- | ${MENU} "Select Wifi 📶 :" | cut -d' ' -f1)
    
    if [ -z "$bssid" ]; then
        echo "No WiFi network selected."
        exit 0
    fi

    # Get password
    pass=$(echo "" | ${MENU} "Enter Password 🔒 :")
    
    # Connect to WiFi (with or without password)
    if [ -n "$pass" ]; then
        if nmcli device wifi connect "$bssid" password "$pass"; then
            echo "Successfully connected to $bssid"
        else
            echo "Failed to connect to $bssid"
            exit 1
        fi
    else
        if nmcli device wifi connect "$bssid"; then
            echo "Successfully connected to $bssid (no password required)"
        else
            echo "Failed to connect to $bssid"
            exit 1
        fi
    fi

    # Test internet connectivity
    sleep 10
    if ping -q -c 2 -W 2 google.com >/dev/null 2>&1; then
        if command -v notify-send >/dev/null 2>&1; then
            notify-send "Your internet is working :)"
        else
            echo "Internet connection test: SUCCESS"
        fi
    else
        if command -v notify-send >/dev/null 2>&1; then
            notify-send "Your internet is not working :("
        else
            echo "Internet connection test: FAILED"
        fi
    fi
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
