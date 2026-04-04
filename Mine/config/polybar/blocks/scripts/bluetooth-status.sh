#!/usr/bin/env bash

# Get connected devices
CONNECTED=$(bluetoothctl devices Connected 2>/dev/null)

if [ -z "$CONNECTED" ]; then
    echo "No Device"
    exit 0
fi

# Process each connected device
OUTPUT=""
while IFS= read -r line; do
    MAC=$(echo "$line" | awk '{print $2}')
    DEVICE=$(echo "$line" | cut -d' ' -f3-)
    
    # Try to get battery level using multiple methods
    BATTERY=""
    
    # Method 1: bluetoothctl info - try different patterns
    INFO=$(bluetoothctl info "$MAC" 2>/dev/null)
    BATTERY=$(echo "$INFO" | grep -i "Battery Percentage" | grep -oP '\(\K[0-9]+')
    
    if [ -z "$BATTERY" ]; then
        BATTERY=$(echo "$INFO" | grep -i "Battery" | grep -oP '[0-9]+' | head -1)
    fi
    
    # Method 2: upower
    if [ -z "$BATTERY" ]; then
        # Try finding by MAC
        UPOWER_PATH=$(upower -e 2>/dev/null | grep -i "$(echo $MAC | tr ':' '_')" | head -1)
        if [ -n "$UPOWER_PATH" ]; then
            BATTERY=$(upower -i "$UPOWER_PATH" 2>/dev/null | grep -i "percentage" | grep -oP '[0-9]+')
        fi
    fi
    
    # Method 3: Check /sys/class/power_supply
    if [ -z "$BATTERY" ]; then
        for bat in /sys/class/power_supply/*/capacity; do
            if [ -f "$bat" ]; then
                BAT_NAME=$(dirname "$bat")
                BAT_NAME=$(basename "$BAT_NAME")
                if echo "$BAT_NAME" | grep -qi "$(echo $MAC | tr ':' '_')"; then
                    BATTERY=$(cat "$bat" 2>/dev/null)
                    break
                fi
            fi
        done
    fi
    
    # Method 4: dbus (works for many devices)
    if [ -z "$BATTERY" ] && command -v dbus-send >/dev/null 2>&1; then
        MAC_UNDERSCORE=$(echo "$MAC" | tr ':' '_')
        BATTERY=$(dbus-send --print-reply --system --dest=org.bluez "/org/bluez/hci0/dev_${MAC_UNDERSCORE}" org.freedesktop.DBus.Properties.Get string:"org.bluez.Battery1" string:"Percentage" 2>/dev/null | grep -oP 'byte \K[0-9]+')
    fi
    
    # Format output
    if [ -n "$BATTERY" ]; then
        if [ -z "$OUTPUT" ]; then
            OUTPUT="$DEVICE ($BATTERY%)"
        else
            OUTPUT="$OUTPUT / $DEVICE ($BATTERY%)"
        fi
    else
        if [ -z "$OUTPUT" ]; then
            OUTPUT="$DEVICE"
        else
            OUTPUT="$OUTPUT / $DEVICE"
        fi
    fi
done <<< "$CONNECTED"

echo "$OUTPUT"
