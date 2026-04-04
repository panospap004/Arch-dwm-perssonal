#!/usr/bin/env bash
# WORKS
# Script name: pipewire-out-switcher
# Description: Switch default output for pipewire using device descriptions.
# Dependencies: dmenu OR fzf OR rofi, pipewire, jq, pactl

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
Description: Switch default output for pipewire.
Dependencies: dmenu OR fzf OR rofi, pipewire, jq, pactl

The following OPTIONS are accepted:
    -h  displays this help page
    -d  runs the script using 'dmenu'
    -f  runs the script using 'fzf'
    -r  runs the script using 'rofi'

Running $(basename "$0") without any argument defaults to using 'dmenu'

Note: This script requires PipeWire, pactl, and jq to be installed."
}

get_default_sink() {
    pactl --format=json info | jq -r .default_sink_name
}

get_current_sink_description() {
    current_sink=$(get_default_sink)
    pactl --format=json list sinks | jq -r --arg current "$current_sink" '.[] | select(.name == $current) | .description'
}

get_all_sink_descriptions() {
    current_desc=$(get_current_sink_description)
    pactl --format=json list sinks | jq -r --arg current "$current_desc" '.[] | if .description == $current then "* " + .description else .description end'
}

# Fallback function if jq is not available
get_all_sink_descriptions_fallback() {
    current=$(pactl info | grep "Default Sink:" | awk '{print $3}')
    pactl list sinks | awk -v current="$current" '
        /^Sink #/ { 
            if (name && desc) {
                marker = (name == current) ? "* " : ""
                print marker desc
            }
            name = ""
            desc = ""
        }
        /^\s*Name:/ { name = $2 }
        /^\s*Description:/ { 
            sub(/^\s*Description: /, "")
            desc = $0
        }
        END {
            if (name && desc) {
                marker = (name == current) ? "* " : ""
                print marker desc
            }
        }
    '
}

get_sink_name_by_description() {
    local description="$1"
    pactl --format=json list sinks | jq -r --arg desc "$description" '.[] | select(.description == $desc) | .name'
}

get_sink_name_by_description_fallback() {
    local description="$1"
    pactl list sinks | awk -v target_desc="$description" '
        /^Sink #/ { 
            if (name && desc == target_desc) {
                print name
                exit
            }
            name = ""
            desc = ""
        }
        /^\s*Name:/ { name = $2 }
        /^\s*Description:/ { 
            sub(/^\s*Description: /, "")
            desc = $0
        }
        END {
            if (name && desc == target_desc) {
                print name
            }
        }
    '
}

get_default_sink_fallback() {
    pactl info | grep "Default Sink:" | awk '{print $3}'
}

get_current_sink_description_fallback() {
    current_sink=$(get_default_sink_fallback)
    pactl list sinks | awk -v target="$current_sink" '
        /^Sink #/ { 
            if (name == target && desc) {
                print desc
                exit
            }
            name = ""
            desc = ""
        }
        /^\s*Name:/ { name = $2 }
        /^\s*Description:/ { 
            sub(/^\s*Description: /, "")
            desc = $0
        }
        END {
            if (name == target && desc) {
                print desc
            }
        }
    '
}

main() {
    # Check dependencies
    if ! command -v pactl >/dev/null 2>&1; then
        err "pactl (PulseAudio/PipeWire) is required but not installed"
    fi

    # Check if jq is available, use fallback if not
    local use_jq=true
    if ! command -v jq >/dev/null 2>&1; then
        echo "Warning: jq not found, using fallback method"
        use_jq=false
    fi

    # Get list of sink descriptions
    if [ "$use_jq" = true ]; then
        descriptions=$(get_all_sink_descriptions 2>/dev/null) || {
            echo "JSON parsing failed, falling back to basic method"
            use_jq=false
        }
    fi
    
    if [ "$use_jq" = false ]; then
        descriptions=$(get_all_sink_descriptions_fallback)
    fi

    if [ -z "$descriptions" ]; then
        err "No audio sinks found"
    fi

    # Show sink selection menu
    choice=$(printf '%s\n' "$descriptions" | sort | ${MENU} 'Sink: ') || exit 1

    if [ -z "$choice" ]; then
        echo "No sink selected."
        exit 0
    fi

    # Remove the asterisk marker if present
    selected_description=$(echo "$choice" | sed 's/^\* //')

    # Check if the selected sink is already the default
    if [ "$use_jq" = true ]; then
        current_description=$(get_current_sink_description 2>/dev/null || get_current_sink_description_fallback)
    else
        current_description=$(get_current_sink_description_fallback)
    fi

    if [ "$selected_description" = "$current_description" ]; then
        echo "Sink '$selected_description' is already the default."
        exit 0
    fi

    # Get the actual sink name from the description
    if [ "$use_jq" = true ]; then
        sink_name=$(get_sink_name_by_description "$selected_description" 2>/dev/null || get_sink_name_by_description_fallback "$selected_description")
    else
        sink_name=$(get_sink_name_by_description_fallback "$selected_description")
    fi

    if [ -z "$sink_name" ]; then
        err "Could not find sink name for: $selected_description"
    fi

    # Set the new default sink
    if pactl set-default-sink "$sink_name"; then
        echo "Default sink changed to: $selected_description"
        if command -v notify-send >/dev/null 2>&1; then
            notify-send "Sink is now: $selected_description"
        fi
    else
        err "Failed to set default sink to: $selected_description"
    fi
}

MENU="$(get_menu_program "$@")"
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main
