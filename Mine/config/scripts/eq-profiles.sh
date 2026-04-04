#!/usr/bin/env bash
# WORKS
# Script name: eq-profiles
# Description: Allows you to switch between predefined equalizer profiles easily.
# Dependencies: dmenu OR fzf OR rofi, easyeffects

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
Description: Allows you to switch between predefined equalizer profiles easily.
Dependencies: dmenu OR fzf OR rofi, easyeffects

The following OPTIONS are accepted:
    -h  displays this help page
    -d  runs the script using 'dmenu'
    -f  runs the script using 'fzf'
    -r  runs the script using 'rofi'

Running $(basename "$0") without any argument defaults to using 'dmenu'

Note: This script requires EasyEffects to be installed and configured with profiles.
Avoid using commas in preset names as it will cause parsing errors."
}

main() {
    # Check if easyeffects is available
    if ! command -v easyeffects >/dev/null 2>&1; then
        err "easyeffects is required but not installed"
    fi

    # Retrieve profiles from easyeffects
    all_profiles=$(easyeffects -p 2>/dev/null) || {
        err "Failed to retrieve EasyEffects profiles. Make sure EasyEffects is properly configured."
    }

    if [ -z "$all_profiles" ]; then
        err "No EasyEffects profiles found. Please create profiles in EasyEffects first."
    fi

    # Separate output and input profiles
    output_profiles=$(echo "${all_profiles}" | head -1)
    input_profiles=$(echo "${all_profiles}" | tail -1)

    # Trim the beginning of I/O profiles
    output_profiles="${output_profiles#*Output: }"
    output_profiles="${output_profiles#Output presets: }"
    input_profiles="${input_profiles#*Input: }"
    input_profiles="${input_profiles#Input presets: }"

    # Convert comma-separated strings to arrays
    IFS=',' read -r -a output_array <<< "${output_profiles}"
    IFS=',' read -r -a input_array <<< "${input_profiles}"

    declare -a eq_profiles

    # Add output profiles with O: prefix
    for element in "${output_array[@]}"; do
        # Trim whitespace
        element=$(echo "$element" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        if [ -n "$element" ]; then
            eq_profiles+=("O: ${element}")
        fi
    done

    # Add input profiles with I: prefix
    for element in "${input_array[@]}"; do
        # Trim whitespace
        element=$(echo "$element" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        if [ -n "$element" ]; then
            eq_profiles+=("I: ${element}")
        fi
    done

    eq_profiles+=("Quit")

    if [ ${#eq_profiles[@]} -le 1 ]; then
        err "No valid EasyEffects profiles found. Please create and save profiles in EasyEffects."
    fi

    # Show profile selection menu
    _profile=$(printf '%s\n' "${eq_profiles[@]}" | ${MENU} "Choose a profile:") || exit 1

    if [[ -z "$_profile" ]]; then
        echo "No profile selected."
        exit 0
    fi

    if [[ $_profile == "Quit" ]]; then 
        echo "Program terminated"
        exit 0
    fi

    # Extract profile name (remove O: or I: prefix)
    profile_name="${_profile:3}"

    # Load the selected profile
    if easyeffects -l "$profile_name" 2>/dev/null; then
        echo "Loaded profile: $profile_name"
        if command -v notify-send >/dev/null 2>&1; then
            notify-send "EasyEffects Profile" "Loaded: $profile_name"
        fi
    else
        err "Failed to load profile: $profile_name"
    fi
}

MENU="$(get_menu_program "$@")"
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main
