#!/usr/bin/env bash

RESULT=""

# Try NVIDIA
if command -v nvidia-smi >/dev/null 2>&1; then
    NVIDIA_TEMPS=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | awk '{print $1"°C"}')
    if [ -n "$NVIDIA_TEMPS" ]; then
        RESULT=$(echo "$NVIDIA_TEMPS" | tr '\n' '/' | sed 's/\/$//')
    fi
fi

# Try AMD
if command -v sensors >/dev/null 2>&1; then
    AMD_TEMPS=$(sensors 2>/dev/null | grep -A 2 "amdgpu" | grep -E "edge|junction" | awk '{gsub(/[+°C]/,""); print int($2)"°C"}')
    if [ -n "$AMD_TEMPS" ]; then
        AMD_RESULT=$(echo "$AMD_TEMPS" | tr '\n' '/' | sed 's/\/$//')
        if [ -n "$RESULT" ]; then
            RESULT="$RESULT/$AMD_RESULT"
        else
            RESULT="$AMD_RESULT"
        fi
    fi
fi

# Try Intel - multiple methods
INTEL_TEMP=""

# Method 1: Check DRM subsystem for Intel GPU temp
for card in /sys/class/drm/card*/device; do
    if [ -f "$card/vendor" ]; then
        VENDOR=$(cat "$card/vendor" 2>/dev/null)
        if [ "$VENDOR" = "0x8086" ]; then  # Intel vendor ID
            # Look for hwmon temp sensors
            for hwmon in "$card"/hwmon/hwmon*/temp*_input; do
                if [ -f "$hwmon" ]; then
                    TEMP=$(cat "$hwmon" 2>/dev/null)
                    if [ -n "$TEMP" ] && [ "$TEMP" -gt 0 ]; then
                        TEMP=$((TEMP / 1000))
                        INTEL_TEMP="${TEMP}°C"
                        break 2
                    fi
                fi
            done
        fi
    fi
done

# Method 2: Try sensors for Intel graphics
if [ -z "$INTEL_TEMP" ] && command -v sensors >/dev/null 2>&1; then
    INTEL_TEMP=$(sensors 2>/dev/null | grep -i "i915" -A 5 | grep -i "temp" | head -1 | awk '{gsub(/[+°C]/,""); print int($2)"°C"}')
fi

# Method 3: Check for Intel integrated graphics via PCI
if [ -z "$INTEL_TEMP" ]; then
    for temp_input in /sys/class/hwmon/hwmon*/temp*_input; do
        if [ -f "$temp_input" ]; then
            HWMON_DIR=$(dirname "$temp_input")
            NAME_FILE="$HWMON_DIR/name"
            if [ -f "$NAME_FILE" ]; then
                NAME=$(cat "$NAME_FILE" 2>/dev/null)
                if echo "$NAME" | grep -qi "i915\|intel"; then
                    TEMP=$(cat "$temp_input" 2>/dev/null)
                    if [ -n "$TEMP" ] && [ "$TEMP" -gt 0 ]; then
                        TEMP=$((TEMP / 1000))
                        INTEL_TEMP="${TEMP}°C"
                        break
                    fi
                fi
            fi
        fi
    done
fi

if [ -n "$INTEL_TEMP" ]; then
    if [ -n "$RESULT" ]; then
        RESULT="$RESULT/$INTEL_TEMP"
    else
        RESULT="$INTEL_TEMP"
    fi
fi

if [ -z "$RESULT" ]; then
    echo "N/A"
else
    echo "$RESULT"
fi
