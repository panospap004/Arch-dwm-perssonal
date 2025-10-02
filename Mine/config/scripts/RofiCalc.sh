#!/bin/bash
# WORKS
# needs rofi-calc
# Calculator using rofi-calc with history integration
rofi_config="$HOME/.config/rofi/config-calc.rasi"

# First, let's update the main rofi config to include calc mode
history_file="$HOME/.cache/rofi-calc-history"

# Kill Rofi if already running before execution
if pgrep -x "rofi" >/dev/null; then
    pkill rofi
fi

# Note: Skipping rofi-calc check due to potential segfault
# The script will fail gracefully if rofi-calc is not installed

# Create history file if it doesn't exist
touch "$history_file"

# Function to add to history
add_to_history() {
    local calculation="$1"
    
    # Remove the entry if it already exists
    sed -i "\|^${calculation}$|d" "$history_file" 2>/dev/null
    
    # Add to top of history
    echo "$calculation" | cat - "$history_file" > /tmp/calc_temp && mv /tmp/calc_temp "$history_file"
    
    # Keep only last 100 entries
    sed -i '101,$d' "$history_file"
}

# Function to get history for rofi-calc
setup_rofi_calc_history() {
    # rofi-calc uses its own history mechanism, but we can pre-populate
    # the rofi history file if it exists
    local rofi_calc_history="$HOME/.cache/rofi-calc.history"
    
    if [[ -s "$history_file" && ! -s "$rofi_calc_history" ]]; then
        # If we have our custom history but rofi-calc doesn't, seed it
        cp "$history_file" "$rofi_calc_history" 2>/dev/null
    fi
}

# Setup history integration
setup_rofi_calc_history

# Launch rofi-calc with custom config
# rofi-calc automatically provides:
# - Live calculation as you type
# - Built-in history
# - Copy to clipboard functionality
# - All the qalc features (units, currency, etc.)

rofi -show calc -modi "calc" -config "$rofi_config"

# Note: rofi-calc handles everything automatically:
# - Live preview as you type
# - History management
# - Clipboard integration
# - No need for manual loops or result handling
