#!/bin/bash
# WORKS
# DWM Idle Toggle Script - No environment variables
# Simple toggle for dwm keybinds with notifications

# REPLACE dwm-test with your actual username
USERNAME="dwm-test"
STATE_FILE="/home/dwm-test/.screen_toggle_state"
LOCK_FILE="/tmp/screen_toggle.lock"

# Default timeouts (in seconds) when screen management is OFF
DEFAULT_BLANK=600      # 10 minutes
DEFAULT_STANDBY=660    # 11 minutes  
DEFAULT_SUSPEND=720    # 12 minutes
DEFAULT_OFF=780        # 13 minutes

# Function to get current state
get_state() {
    if [[ -f "/home/dwm-test/.screen_toggle_state" ]]; then
        cat "/home/dwm-test/.screen_toggle_state"
    else
        echo "OFF"
    fi
}

# Function to enable screen staying on (disable power management)
enable_always_on() {
    # Create state file directory if it doesn't exist
    /bin/mkdir -p "/home/dwm-test"
    
    # Disable screensaver
    /usr/bin/xset s off
    
    # Disable DPMS (Display Power Management Signaling)
    /usr/bin/xset -dpms
    
    # Set screen saver timeout to 0 (disabled)
    /usr/bin/xset s 0 0

    # Disable xautolock if it's running
    /usr/bin/xautolock -disable 2>/dev/null || true
    
    echo "ON" > "/home/dwm-test/.screen_toggle_state"
    /usr/bin/notify-send "󰈈 Idle Inhibitor" "Screen will stay on - power management disabled" --icon=display
}

# Function to restore normal screen management
restore_normal() {
    # Create state file directory if it doesn't exist
    /bin/mkdir -p "/home/dwm-test"
    
    # Enable screensaver
    /usr/bin/xset s on
    
    # Enable DPMS
    /usr/bin/xset +dpms
    
    # Set timeouts: blank, standby, suspend, off
    /usr/bin/xset s 600 600
    /usr/bin/xset dpms 660 720 780
    
    # Enable xautolock if it was disabled
    /usr/bin/xautolock -enable 2>/dev/null || true
    
    echo "OFF" > "/home/dwm-test/.screen_toggle_state"
    /usr/bin/notify-send "󰈉 Idle Inhibitor" "Screen management restored to normal" --icon=display
}

# Main toggle logic
# Use lock file to prevent multiple instances
if [[ -f "/tmp/screen_toggle.lock" ]]; then
    exit 1
fi

touch "/tmp/screen_toggle.lock"
trap "rm -f /tmp/screen_toggle.lock" EXIT

current_state=$(get_state)

if [[ "$current_state" == "ON" ]]; then
    restore_normal
else
    enable_always_on
fi
