#!/usr/bin/env bash
# WORKS
# Script name: man
# Description: Search for a manpage or get a random one.
# Dependencies: dmenu OR fzf OR rofi, man, a terminal emulator

set -euo pipefail

# Configuration
DMENU="dmenu -i -l 20 -g 2 -p"
RMENU="rofi -i -dmenu -config ~/.config/rofi/config-compact.rasi -p"
FMENU="fzf --bind=enter:replace-query+print-query --border=rounded --margin=5% --color=dark --height 100% --reverse --header=$(basename "$0") --info=hidden --header-first --prompt"
DMTERM="kitty -e"  # Change to your preferred terminal

# Helper functions
err() {
    printf 'Error: %s\n' "$1"
    exit 1
}

get_menu_program() {
    while getopts "dfrh" arg 2>/dev/null; do
        case "${arg}" in
        d) echo "${DMENU}"; return 0 ;;
        f) echo "${FMENU}"; return 0 ;;
        r) echo "${RMENU}"; return 0 ;;
        h) help; return 1 ;;
        *) echo "invalid option: Type $(basename "$0") -h for help" >/dev/stderr; return 1 ;;
        esac
    done
    echo "${DMENU}"
}

help() {
    printf '%s\n' "Usage: $(basename "$0") [options]
Description: Search for a manpage or get a random one.
Dependencies: dmenu OR fzf OR rofi, man, a terminal emulator

The following OPTIONS are accepted:
    -h  displays this help page
    -d  runs the script using 'dmenu'
    -f  runs the script using 'fzf'
    -r  runs the script using 'rofi'

Running $(basename "$0") without any argument defaults to using 'dmenu'"
}

main() {
    # Check if man is available
    if ! command -v man >/dev/null 2>&1; then
        err "man command is required but not installed"
    fi

    # Check if terminal is available
    if ! command -v ${DMTERM%% *} >/dev/null 2>&1; then
        echo "Warning: Terminal '${DMTERM%% *}' not found, using xterm as fallback"
        DMTERM="xterm -e"
    fi

    # Options array
    local _options=("Search manpages" "Random manpage" "Quit")
    
    # Show menu
    choice=$(printf '%s\n' "${_options[@]}" | ${MENU} 'Manpages:')

    # Handle choice
    case "$choice" in
    'Search manpages')
        # Search and display manpages
        man -k . | awk '{$3="-"; print $0}' \
            | ${MENU} 'Search for:' \
            | awk -F '(' '{print $1}' | xargs $DMTERM man
        ;;
    'Random manpage')
        # Get random manpage
        man -k . | shuf -n 1 | awk '{$3="-"; print $0}' \
            | ${MENU} 'Random manpage:' \
            | awk -F '(' '{print $1}' | xargs $DMTERM man
        ;;
    'Quit')
        echo "Program terminated." && exit 0
        ;;
    *)
        exit 0
        ;;
    esac
}

MENU="$(get_menu_program "$@")"
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main
