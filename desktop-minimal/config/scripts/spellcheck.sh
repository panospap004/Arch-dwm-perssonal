#!/usr/bin/env bash
# WORKS
# Script name: spellcheck
# Description: Uses didyoumean as a spellchecker.
# Dependencies: dmenu OR fzf OR rofi, didyoumean, xclip

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
Description: Uses didyoumean as a spellchecker.
Dependencies: dmenu OR fzf OR rofi, didyoumean, xclip

The following OPTIONS are accepted:
    -h  displays this help page
    -d  runs the script using 'dmenu'
    -f  runs the script using 'fzf'
    -r  runs the script using 'rofi'

Running $(basename "$0") without any argument defaults to using 'dmenu'

Note: This script requires 'didyoumean' and 'xclip' to be installed.
The corrected spelling will be copied to clipboard."
}

# Function to copy to clipboard
cp2cb() {
    case "$XDG_SESSION_TYPE" in
    'x11') 
        if command -v xclip >/dev/null 2>&1; then
            xclip -selection clipboard
        else
            echo "xclip is required for X11 clipboard support"
        fi
        ;;
    'wayland') 
        if command -v wl-copy >/dev/null 2>&1; then
            wl-copy -n
        else
            echo "wl-clipboard is required for Wayland clipboard support"
        fi
        ;;
    *) 
        echo "Unknown display server - cannot copy to clipboard"
        cat  # Just output to stdout
        ;;
    esac
}

main() {
    # Check dependencies
    if ! command -v dym >/dev/null 2>&1; then
        err "didyoumean (dym) is required but not installed. Install it with: pip install didyoumean"
    fi

    # Get word to check
    WORD="$(printf '%s' "" | ${MENU} "Enter Word:")"

    if [ -z "${WORD}" ] || [ "${WORD}" = "quit" ]; then
        printf 'No word inserted\n' >&2
        exit 0
    fi

    # Check spelling and get suggestions
    suggestions=$(dym -c "$WORD" 2>/dev/null)
    
    if [ -z "$suggestions" ]; then
        echo "No spelling suggestions found for: $WORD"
        exit 1
    fi

    # Select correct spelling
    corrected=$(echo "$suggestions" | ${MENU} "Select Correct Spelling:")
    
    if [ -n "$corrected" ]; then
        echo "$corrected" | cp2cb
        echo "Copied to clipboard: $corrected"
    else
        echo "No correction selected."
    fi
}

MENU="$(get_menu_program "$@")"
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main
