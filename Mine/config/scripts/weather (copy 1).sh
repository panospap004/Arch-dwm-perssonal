#!/usr/bin/env bash
# WORKS
# Script name: dm-weather
# Description: Simple graphical weather app
# Dependencies: dmenu OR fzf OR rofi, curl, yad

set -euo pipefail

# Configuration
DMENU="dmenu -i -l 20 -g 2 -p"
RMENU="rofi -i -dmenu -config ~/.config/rofi/config-compact.rasi -p"
FMENU="fzf --bind=enter:replace-query+print-query --border=rounded --margin=5% --color=dark --height 100% --reverse --header=$(basename "$0") --info=hidden --header-first --prompt"

# Weather locations - add your preferred locations here
weather_locations="Athens, Greece
New York, United States
London, United Kingdom
Tokyo, Japan
Paris, France
Berlin, Germany
Sydney, Australia
Los Angeles, United States
Miami, United States"

# Weather options - additional flags for wttr.in
weather_opts=""

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
Description: Simple graphical weather app
Dependencies: dmenu OR fzf OR rofi, curl, yad

The following OPTIONS are accepted:
    -h  displays this help page
    -d  runs the script using 'dmenu'
    -f  runs the script using 'fzf'
    -r  runs the script using 'rofi'

Running $(basename "$0") without any argument defaults to using 'dmenu'

Note: This script uses wttr.in web service to fetch weather data.
If yad is not available, weather will be displayed in terminal."
}

display_weather() {
    local location="$1"
    local weather_data

    # Fetch weather data
    weather_data=$(curl -s "https://wttr.in/${location// /%20}?T&${weather_opts}" 2>/dev/null)
    
    if [ -z "$weather_data" ]; then
        err "Failed to fetch weather data for $location. Check your internet connection."
    fi

    # Display weather using yad if available, otherwise use terminal
    if command -v yad >/dev/null 2>&1; then
        echo "$weather_data" | yad --text-info --maximized --title="Weather for $location"
    else
        echo "Weather for $location:"
        echo "========================"
        echo "$weather_data"
    fi
}

main() {
    # Check dependencies
    if ! command -v curl >/dev/null 2>&1; then
        err "curl is required but not installed"
    fi

    # If weather_locations is empty, allow manual entry
    if [ -z "$weather_locations" ]; then
        _location=$(echo "" | ${MENU} "Enter location for weather:")
        if [ -z "$_location" ]; then
            echo "No location entered."
            exit 0
        fi
    else
        # Select from predefined locations or enter custom
        _location="$(printf '%s\n' "$weather_locations" "Enter custom location..." | ${MENU} "Where do you want to see the weather?")"
        
        if [ -z "$_location" ]; then
            echo "No location selected."
            exit 0
        fi
        
        if [ "$_location" = "Enter custom location..." ]; then
            _location=$(echo "" | ${MENU} "Enter custom location:")
            if [ -z "$_location" ]; then
                echo "No location entered."
                exit 0
            fi
        fi
    fi

    echo "Fetching weather for: $_location"
    
    # If weather_opts is unset, give it an empty value
    weather_opts="${weather_opts:-}"

    # Display weather
    display_weather "$_location"
}

MENU="$(get_menu_program "$@")"
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main
