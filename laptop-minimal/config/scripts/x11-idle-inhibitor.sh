#!/bin/bash
# WORKS
# Idle Check and Status Script
# For terminal use and polybar

# Configuration - hardcoded paths, no variables
STATE_FILE="/home/dwm-test/.screen_toggle_state"

# Function to get current state
get_state() {
    if [[ -f "/home/dwm-test/.screen_toggle_state" ]]; then
        cat "/home/dwm-test/.screen_toggle_state"
    else
        echo "OFF"
    fi
}

# Function to show current status for polybar
status() {
    current_state=$(get_state)
    if [[ "$current_state" == "ON" ]]; then
        echo "󰈈"  # Icon when screen staying on
    else
        echo "󰈉"  # Icon when normal power management
    fi
}

# Function to show detailed status
detailed_status() {
    current_state=$(get_state)

    # Check xautolock status
    xautolock_status="Unknown"
    if /bin/ps aux | /bin/grep -q "[x]autolock"; then
        # xautolock is running, check if it's enabled or disabled
        if /usr/bin/xautolock -time 1 -locker /bin/true 2>/dev/null; then
            xautolock_status="Running and Enabled"
        else
            xautolock_status="Running but Disabled"
        fi
    else
        xautolock_status="Not Running"
    fi

    if [[ "$current_state" == "ON" ]]; then
        /usr/bin/notify-send "Idle Inhibitor Status" "Screen Always On: ENABLED" --icon=display
        echo "Screen Always On: ENABLED"
        echo "DPMS Status: $(/usr/bin/xset q | /bin/grep "DPMS is" | /usr/bin/cut -d' ' -f3)"
        echo "Screensaver: $(/usr/bin/xset q | /bin/grep "Screen Saver" -A1 | /usr/bin/tail -1 | /usr/bin/xargs)"
    else
        /usr/bin/notify-send "Idle Inhibitor Status" "Screen Always On: DISABLED" --icon=display
        echo "Screen Always On: DISABLED"
        echo "DPMS Status: $(/usr/bin/xset q | /bin/grep "DPMS is" | /usr/bin/cut -d' ' -f3)"
        echo "Screensaver: $(/usr/bin/xset q | /bin/grep "Screen Saver" -A1 | /usr/bin/tail -1 | /usr/bin/xargs)"
    fi
}

# Main script logic
case "${1:-status}" in
    "status")
        status
        ;;
    "check"|"info")
        detailed_status
        ;;
    *)
        /usr/bin/notify-send "Idle Script Usage" "Available commands: status, check"
        echo "Usage: /home/dwm-test/.config/scripts/idle-status.sh [status|check]"
        echo ""
        echo "Commands:"
        echo "  status  - Show icon status (for polybar)"
        echo "  check   - Show detailed status information"
        echo ""
        echo "Current state: $(get_state)"
        exit 1
        ;;
esac
