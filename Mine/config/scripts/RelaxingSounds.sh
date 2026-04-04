#!/usr/bin/env bash
# WORKS
# Script name: RelaxingSounds
# Description: Choose a ambient background sound to play.
# Dependencies: dmenu OR fzf OR rofi, mpv

set -euo pipefail

# Configuration
DMENU="dmenu -noi -l 20 -g 2 -p"
RMENU="rofi -i -dmenu -config ~/.config/rofi/config-rofi-Beats.rasi -p"
FMENU="fzf --bind=enter:replace-query+print-query --border=rounded --margin=5% --color=dark --height 100% --reverse --header=$(basename "$0") --info=hidden --header-first --prompt"

# Sounds directory - change to your preferred location
sounds_dir="${HOME}/.config/scripts/sounds/"

# Cache file for storing PID
cache_file="$HOME/.cache/RelaxingSounds"

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
Description: Choose a ambient background sound to play.
Dependencies: dmenu OR fzf OR rofi, mpv

The following OPTIONS are accepted:
    -h  displays this help page
    -d  runs the script using 'dmenu'
    -f  runs the script using 'fzf'
    -r  runs the script using 'rofi'

Running $(basename "$0") without any argument defaults to using 'dmenu'

Sound files should be placed in: $sounds_dir
Supported formats: .mp3, .m4a, .ogg

You can download ambient sounds from:
https://gitlab.com/dtos/etc/dtos-dmscripts/-/tree/main/etc/dtos/.config/dmscripts/dmsounds"
}

stop_sounds() {
    local stopped=false
    
    # Method 1: Kill using cached PID
    if [ -f "$cache_file" ]; then
        local pid
        pid=$(cat "$cache_file" 2>/dev/null)
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            if kill "$pid" 2>/dev/null; then
                echo "Stopped sound player (PID: $pid)"
                stopped=true
            fi
        fi
        rm -f "$cache_file"
    fi
    
    # Method 2: Kill all mpv processes playing from sounds directory (fallback)
    local mpv_pids
    mapfile -t mpv_pids < <(pgrep -f "mpv.*${sounds_dir}" 2>/dev/null || true)
    
    if [ ${#mpv_pids[@]} -gt 0 ]; then
        for pid in "${mpv_pids[@]}"; do
            if kill "$pid" 2>/dev/null; then
                echo "Stopped additional mpv process (PID: $pid)"
                stopped=true
            fi
        done
    fi
    
    # Method 3: Kill all mpv processes (last resort)
    if [ "$stopped" = false ]; then
        if pkill mpv 2>/dev/null; then
            echo "Stopped all mpv processes"
            stopped=true
        fi
    fi
    
    if [ "$stopped" = false ]; then
        echo "No running sound players found"
    fi
}

main() {
    # Check if mpv is available
    if ! command -v mpv >/dev/null 2>&1; then
        err "mpv is required but not installed"
    fi

    # Check if sounds directory exists
    if [ ! -d "${sounds_dir}" ]; then
        err "The sounds folder could not be found.
Place your sounds in: ${sounds_dir}
Here are 15 sounds that you can download:
https://gitlab.com/dtos/etc/dtos-dmscripts/-/tree/main/etc/dtos/.config/dmscripts/dmsounds

Create the directory and place sound files there."
    fi

    # Create cache directory if it doesn't exist
    mkdir -p "$(dirname "$cache_file")"

    # Get list of sound files
    readarray -t _sounds_list < <(find "${sounds_dir}" \( -iname "*.mp3" -o -iname "*.m4a" -o -iname "*.ogg" \) -printf '%P\n' 2>/dev/null || find "${sounds_dir}" \( -iname "*.mp3" -o -iname "*.m4a" -o -iname "*.ogg" \) -exec basename {} \;)

    if [ ${#_sounds_list[@]} -eq 0 ]; then
        err "No sound files found in ${sounds_dir}
Please add .mp3, .m4a, or .ogg files to this directory."
    fi

    echo "Found ${#_sounds_list[@]} sound files"

    # Array of options to choose
    local _options=(
        "Choose sound file"
        "Play random sound"
        "Stop sound player"
        "Quit"
    )

    # Show menu
    choice=$(printf '%s\n' "${_options[@]}" | ${MENU} 'Ambient sounds:')

    case "$choice" in
        "Choose sound file")
            # Choose specific sound file
            choice=$(printf '%s\n' "${_sounds_list[@]}" | sort | ${MENU} 'Choose sound file:')
            if [ -n "$choice" ]; then
                # Stop any existing sounds first
                stop_sounds
                
                # Play the chosen sound file
                mpv --no-video --loop "$sounds_dir/$choice" >/dev/null 2>&1 &
                # Save PID for later termination
                _pid=$!
                echo "$_pid" > "$cache_file"
                echo "Playing: $choice"
            fi
            ;;
        "Play random sound")
            get_rand=$(printf '%s\n' "${_sounds_list[@]}" | shuf -n 1)
            
            # Stop any existing sounds first
            stop_sounds
            
            # Play random sound file
            mpv --no-video --loop "$sounds_dir/$get_rand" >/dev/null 2>&1 &
            # Save PID for later termination
            _pid=$!
            echo "$_pid" > "$cache_file"
            echo "Playing random sound: $get_rand"
            ;;
        "Stop sound player")
            stop_sounds
            ;;
        *)
            echo "Program terminated." && exit 0
            ;;
    esac
}

MENU="$(get_menu_program "$@")"
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main
