#!/usr/bin/env bash
# WORKS
# Script name: dictionary
# Description: Uses the translate package as a dictionary.
# Dependencies: dmenu OR fzf OR rofi, translate-shell, didyoumean {use bin version}, notify-send
#    -h  displays this help page
#    -d  runs the script using 'dmenu'
#    -f  runs the script using 'fzf'
#    -r  runs the script using 'rofi'


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

help() {
    printf '%s\n' "Usage: $(basename "$0") [options]
Description: Uses the translate package as a dictionary.
Dependencies: dmenu OR fzf OR rofi, translate-shell, didyoumean, notify-send

The folowing OPTIONS are accepted:
    -h  displays this help page
    -d  runs the script using 'dmenu'
    -f  runs the script using 'fzf'
    -r  runs the script using 'rofi'

Running $(basename "$0") without any argument defaults to using 'dmenu'

Required packages:
- translate-shell (provides 'trans' command)
- didyoumean (provides 'dym' command)
- libnotify (provides 'notify-send' command)"
}

main() {
    # Check dependencies
    if ! command -v trans >/dev/null 2>&1; then
        err "translate-shell (trans command) is required but not installed"
    fi

    if ! command -v dym >/dev/null 2>&1; then
        err "didyoumean (dym command) is required but not installed"
    fi

    if ! command -v notify-send >/dev/null 2>&1; then
        err "notify-send (libnotify) is required but not installed"
    fi

    # Get word to lookup
    word="$(echo "" | ${MENU} "Enter word to lookup:")"

    if [ -z "$word" ]; then
        notify-send "Dictionary" "No word entered" --urgency=low --expire-time=3000
        exit 0
    fi

    # Check spelling and get suggestions
    testword="$(dym -c -n=1 "$word" 2>/dev/null || echo "$word")"

    if [ "$word" != "$testword" ]; then
        suggestions=$(dym -c "$word" 2>/dev/null || echo "")
        if [ -n "$suggestions" ]; then
            keyword=$(echo -e "no\n$suggestions" | ${MENU} "Was '$word' a misspelling? (select correction or 'no'):")
            if [ "$keyword" = "no" ] || [ "$keyword" = "n" ] || [ -z "$keyword" ]; then
                keyword="$word"
            fi
        else
            keyword="$word"
        fi
    else
        keyword="$word"
    fi

    if [ -z "${keyword}" ]; then
        notify-send "Dictionary" "No word selected" --urgency=low --expire-time=3000
        exit 0
    fi

    # Get dictionary definition and send notification
    definition=$(trans -d -no-ansi "$keyword" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$definition" ]; then
        # Truncate definition if too long (notifications have character limits)
        if [ ${#definition} -gt 500 ]; then
            definition=$(echo "$definition" | head -c 500)
            definition="$definition..."
        fi
        
        # Send notification with definition
        notify-send "Dictionary: $keyword" "$definition" --urgency=normal --expire-time=15000
    else
        # Try without -d flag as fallback
        definition=$(trans -no-ansi "$keyword" 2>/dev/null | head -5)
        if [ -n "$definition" ]; then
            if [ ${#definition} -gt 500 ]; then
                definition=$(echo "$definition" | head -c 500)
                definition="$definition..."
            fi
            notify-send "Dictionary: $keyword" "$definition" --urgency=normal --expire-time=15000
        else
            notify-send "Dictionary Error" "Could not find definition for: $keyword" --urgency=normal --expire-time=5000
        fi
    fi
}

mainfzf() {
    # Check dependencies
    if ! command -v trans >/dev/null 2>&1; then
        err "translate-shell (trans command) is required but not installed"
    fi

    if ! command -v dym >/dev/null 2>&1; then
        err "didyoumean (dym command) is required but not installed"
    fi

    if ! command -v notify-send >/dev/null 2>&1; then
        err "notify-send (libnotify) is required but not installed"
    fi

    # Get word to lookup using fzf
    word="$(echo "" | fzf --print-query --prompt "Enter word to lookup: " | tail -1)"

    if [ -z "$word" ]; then
        notify-send "Dictionary" "No word entered" --urgency=low --expire-time=3000
        exit 0
    fi

    # Check spelling and get suggestions
    testword="$(dym -c -n=1 "$word" 2>/dev/null || echo "$word")"

    if [ "$word" != "$testword" ]; then
        suggestions=$(dym -c "$word" 2>/dev/null || echo "")
        if [ -n "$suggestions" ]; then
            keyword=$(echo -e "no\n$suggestions" | ${FMENU} "Was '$word' a misspelling? (select correction or 'no'):")
            if [ "$keyword" = "no" ] || [ "$keyword" = "n" ] || [ -z "$keyword" ]; then
                keyword="$word"
            fi
        else
            keyword="$word"
        fi
    else
        keyword="$word"
    fi

    if [ -z "${keyword}" ]; then
        notify-send "Dictionary" "No word selected" --urgency=low --expire-time=3000
        exit 0
    fi

    # Get dictionary definition and send notification
    definition=$(trans -d -no-ansi "$keyword" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$definition" ]; then
        # Truncate definition if too long (notifications have character limits)
        if [ ${#definition} -gt 500 ]; then
            definition=$(echo "$definition" | head -c 500)
            definition="$definition..."
        fi
        
        # Send notification with definition
        notify-send "Dictionary: $keyword" "$definition" --urgency=normal --expire-time=15000
    else
        # Try without -d flag as fallback
        definition=$(trans -no-ansi "$keyword" 2>/dev/null | head -5)
        if [ -n "$definition" ]; then
            if [ ${#definition} -gt 500 ]; then
                definition=$(echo "$definition" | head -c 500)
                definition="$definition..."
            fi
            notify-send "Dictionary: $keyword" "$definition" --urgency=normal --expire-time=15000
        else
            notify-send "Dictionary Error" "Could not find definition for: $keyword" --urgency=normal --expire-time=5000
        fi
    fi
}

no_opt=1
while getopts "dfrh" arg 2>/dev/null; do
    case "${arg}" in
    d) 
        MENU=${DMENU}
        [[ "${BASH_SOURCE[0]}" == "${0}" ]] && main
        ;;
    f) 
        [[ "${BASH_SOURCE[0]}" == "${0}" ]] && mainfzf
        ;;
    r) 
        MENU=${RMENU}
        [[ "${BASH_SOURCE[0]}" == "${0}" ]] && main
        ;;
    h) help ;;
    *) printf '%s\n' "Error: invalid option" "Type $(basename "$0") -h for help" ;;
    esac
    no_opt=0
done

# If script is run with NO argument, default to dmenu
[ $no_opt = 1 ] && MENU=${DMENU} && [[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
