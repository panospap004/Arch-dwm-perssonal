#!/usr/bin/env bash

# Try different methods to get CPU temp
TEMP=""

# Method 1: sensors with various patterns
if command -v sensors >/dev/null 2>&1; then
    TEMP=$(sensors 2>/dev/null | grep -E "Core 0|Package id 0|Tctl|Tdie|CPU Temperature" | head -1 | grep -oP '\+\K[0-9]+' | head -1)
fi

# Method 2: thermal zone (fallback)
if [ -z "$TEMP" ]; then
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
        TEMP=$((TEMP / 1000))
    fi
fi

# Method 3: Check other thermal zones
if [ -z "$TEMP" ]; then
    for zone in /sys/class/thermal/thermal_zone*/temp; do
        if [ -f "$zone" ]; then
            TEMP=$(cat "$zone")
            TEMP=$((TEMP / 1000))
            break
        fi
    done
fi

if [ -n "$TEMP" ] && [ "$TEMP" -gt 0 ]; then
    echo "${TEMP}°C"
else
    echo "N/A"
fi
