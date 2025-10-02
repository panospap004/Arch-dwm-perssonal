#!/bin/bash
# WORKS
# Searchable DWM keybinds using rofi
# Kill yad to not interfere with this binds
pkill yad || true

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

# Define the DWM config file (adjust path as needed)
DWM_CONFIG="$HOME/.config/dwm/config.h"
# Alternative common locations - uncomment the one you use:
# DWM_CONFIG="$HOME/dwm/config.h"
# DWM_CONFIG="$HOME/.dwm/config.h"
# DWM_CONFIG="/usr/src/dwm/config.h"

# Check if config file exists
if [[ ! -f "$DWM_CONFIG" ]]; then
    echo "DWM config file not found at: $DWM_CONFIG"
    echo "Please edit the script to point to your dwm config.h file"
    exit 1
fi

# Extract keybinds from DWM config
# This looks for lines with key definitions and TAGKEYS/STACKKEYS macros
KEYBINDS=$(cat "$DWM_CONFIG" | \
    grep -E '^\s*{\s*(MODKEY|Mod1Mask|ShiftMask|ControlMask|0|ClkClientWin|ClkTagBar|MOD).*}.*,' | \
    grep -v '^//' | \
    sed 's/^\s*//g' | \
    sed 's/,\s*$//')

# Also get TAGKEYS and STACKKEYS macro usage
MACRO_KEYS=$(cat "$DWM_CONFIG" | \
    grep -E '^\s*(TAGKEYS|STACKKEYS)\(' | \
    grep -v '^//' | \
    sed 's/^\s*//g')

# Get the actual TAGKEYS and STACKKEYS definitions to show what they expand to
TAGKEYS_DEF=$(cat "$DWM_CONFIG" | \
    grep -A 10 -E '^\s*#define\s+TAGKEYS' | \
    grep -E '^\s*{\s*(MOD|MODKEY).*}.*,' | \
    sed 's/^\s*//g' | \
    sed 's/,\s*$//')

STACKKEYS_DEF=$(cat "$DWM_CONFIG" | \
    grep -A 10 -E '^\s*#define\s+STACKKEYS' | \
    grep -E '^\s*{\s*(MOD|MODKEY).*}.*,' | \
    sed 's/^\s*//g' | \
    sed 's/,\s*$//')

# Combine all keybinds
ALL_KEYBINDS=""

if [[ -n "$KEYBINDS" ]]; then
    ALL_KEYBINDS+="$KEYBINDS"$'\n'
fi

if [[ -n "$MACRO_KEYS" ]]; then
    ALL_KEYBINDS+="$MACRO_KEYS"$'\n'
fi

if [[ -n "$TAGKEYS_DEF" ]]; then
    ALL_KEYBINDS+="--- TAGKEYS Definition ---"$'\n'
    ALL_KEYBINDS+="$TAGKEYS_DEF"$'\n'
fi

if [[ -n "$STACKKEYS_DEF" ]]; then
    ALL_KEYBINDS+="--- STACKKEYS Definition ---"$'\n'
    ALL_KEYBINDS+="$STACKKEYS_DEF"$'\n'
fi

# Check for any keybinds to display
if [[ -z "$ALL_KEYBINDS" ]]; then
    echo "No keybinds found in: $DWM_CONFIG"
    exit 1
fi

# Use rofi to display the keybinds
echo "$ALL_KEYBINDS" | rofi -dmenu -i -p "DWM Keybinds" -config ~/.config/rofi/config-keybinds.rasi
