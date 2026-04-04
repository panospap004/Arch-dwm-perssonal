#!/bin/bash
# DWM workspaces script with custom color support and multi-monitor fix
# Usage: script.sh [background-alt] [foreground] [primary] [occupied] [empty] [urgent]

# Handle color arguments or use defaults/environment variables
back="${1:-${COLOR_BACK:-#423949}}"
fore="${2:-${COLOR_FORE:-#FFFFFF}}"
prim="${3:-${COLOR_PRIM:-#D94085}}"
occupied="${4:-${COLOR_OCCUPIED:-#FFFFFF}}"
empty="${5:-${COLOR_EMPTY:-#9E9E9E}}"
urgent="${6:-${COLOR_URGENT:-#EBD369}}"

# Japanese kanji for tags
kanji=("一" "二" "三" "四" "五" "六" "七" "八" "九")

# Function to format workspace with consistent width
format_workspace() {
    local state="$1"
    local index="$2"
    local kanji_char="${kanji[$index]}"
    
    case "$state" in
        a)
            # Active tag - use primary color with background
            echo -n "%{F$occupied}%{B$prim} $kanji_char %{B-}%{F-}"
            ;;
        o)
            # Occupied tag - white text with background for consistency
            echo -n "%{F$occupied}%{B$back} $kanji_char %{B-}%{F-}"
            ;;
        u)
            # Urgent tag - yellow text with background for consistency
            echo -n "%{F$occupied}%{B$urgent} $kanji_char %{B-}%{F-}"
            ;;
        *)
            # Empty tag - gray text with background for consistency
            echo -n "%{F$empty}%{B$back} $kanji_char %{B-}%{F-}"
            ;;
    esac
}

# Determine which monitor this polybar instance is on
# This relies on the $MONITOR environment variable set by polybar
MONITOR_NAME="${MONITOR:-$(xrandr --query | grep " connected primary" | cut -d" " -f1)}"

# Find the monitor index for DWM
# DWM assigns indices based on the order monitors appear in xrandr
MONITOR_INDEX=0
if [ -n "$MONITOR_NAME" ]; then
    MONITOR_LIST=($(xrandr --query | grep " connected" | cut -d" " -f1))
    for i in "${!MONITOR_LIST[@]}"; do
        if [ "${MONITOR_LIST[$i]}" = "$MONITOR_NAME" ]; then
            MONITOR_INDEX=$i
            break
        fi
    done
fi

DWM_PROPERTY="DWM_TAG_STATE_${MONITOR_INDEX}"

# Initialize with a default state
init_output=""
for i in {0..8}; do
    init_output+=$(format_workspace "e" "$i")
done
echo "$init_output"

# Listen for updates of the tagstate for THIS monitor
xprop -spy -root "$DWM_PROPERTY" 2>/dev/null | {
    while read -r line; do
        # Parse the property line to extract tag state
        if [[ $line =~ \"([^\"]+)\" ]]; then
            tags="${BASH_REMATCH[1]}"
            
            # Build output with consistent formatting
            output=""
            for i in {0..8}; do
                if [[ ${#tags} -gt $i ]]; then
                    output+=$(format_workspace "${tags:$i:1}" "$i")
                else
                    output+=$(format_workspace "e" "$i")
                fi
            done
            echo "$output"
        fi
    done
} 2>/dev/null

# Fallback in case xprop fails
if [[ $? -ne 0 ]]; then
    fallback_output=""
    for i in {0..8}; do
        fallback_output+=$(format_workspace "e" "$i")
    done
    echo "$fallback_output"
fi
