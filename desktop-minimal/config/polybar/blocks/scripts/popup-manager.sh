#!/bin/bash

# Universal Popup Manager Script with Multi-Monitor Support
# Usage: ./popup-manager.sh POPUP_NAME [--toggle|--show|--hide|--status] [MONITOR]

POPUP_NAME="$1"
ACTION="${2:-status}"
MONITOR="${3:-}"  # Optional monitor parameter
STATUSFILE_PATH="$HOME/.config/polybar/blocks/scripts/"
STATUSFILE_PREFIX=".popup."
STATUSFILE="$STATUSFILE_PATH$STATUSFILE_PREFIX$POPUP_NAME"

# If no monitor specified, try to detect from environment or use primary
if [ -z "$MONITOR" ]; then
    MONITOR="${MONITOR:-$(xrandr --query | grep " connected primary" | cut -d" " -f1)}"
    if [ -z "$MONITOR" ]; then
        MONITOR=$(xrandr --query | grep " connected" | cut -d" " -f1 | head -1)
    fi
fi

# Icons for different states (using feather icons like your config)
case "$POPUP_NAME" in
    "bluetooth")
        POPUP_ICON_ACTIVE=""
        POPUP_ICON_INACTIVE=""
        ;;
    "sysinfo")
        POPUP_ICON_ACTIVE=""
        POPUP_ICON_INACTIVE=""
        ;;
    "general")
        POPUP_ICON_ACTIVE=""
        POPUP_ICON_INACTIVE=""
        ;;
    "tray")
        POPUP_ICON_ACTIVE=""
        POPUP_ICON_INACTIVE=""
        ;;
    *)
        POPUP_ICON_ACTIVE=""
        POPUP_ICON_INACTIVE=""
        ;;
esac

function get_popup_pid() {
    ps -ef | grep "polybar.*popup_$POPUP_NAME" | grep -v grep | awk '{print $2}'
}

function kill_all_popups() {
    local pids=$(get_popup_pid)
    if [ ! -z "$pids" ]; then
        echo "$pids" | xargs kill 2>/dev/null
        sleep 0.1
    fi
}

function launch_popup() {
    # Kill all existing instances first
    kill_all_popups
    
    # Launch new popup instance on the specified monitor
    MONITOR="$MONITOR" polybar -q "popup_$POPUP_NAME" -c "$HOME/.config/polybar/blocks/config.ini" &
    sleep 0.2
    
    # Mark as active and store monitor info
    echo "$MONITOR" > "$STATUSFILE"
}

function hide_popup() {
    local pids=$(get_popup_pid)
    if [ ! -z "$pids" ]; then
        echo "$pids" | while read pid; do
            polybar-msg -p "$pid" cmd hide 2>/dev/null
        done
    fi
    rm -f "$STATUSFILE"
}

function show_popup() {
    local pids=$(get_popup_pid)
    if [ ! -z "$pids" ]; then
        # Check if popup is on the correct monitor
        local stored_monitor=""
        if [ -f "$STATUSFILE" ]; then
            stored_monitor=$(cat "$STATUSFILE")
        fi
        
        # If monitor changed or no popup exists, relaunch
        if [ "$stored_monitor" != "$MONITOR" ] || [ -z "$pids" ]; then
            launch_popup
        else
            # Just show existing popup
            echo "$pids" | while read pid; do
                polybar-msg -p "$pid" cmd show 2>/dev/null
            done
            echo "$MONITOR" > "$STATUSFILE"
        fi
    else
        launch_popup
    fi
}

function toggle_popup() {
    if [ -f "$STATUSFILE" ]; then
        local stored_monitor=$(cat "$STATUSFILE")
        # If clicking on same monitor, toggle. If different monitor, show there.
        if [ "$stored_monitor" = "$MONITOR" ]; then
            hide_popup
        else
            launch_popup
        fi
    else
        show_popup
    fi
}

function get_status() {
    if [ -f "$STATUSFILE" ]; then
        echo "$POPUP_ICON_ACTIVE"
    else
        echo "$POPUP_ICON_INACTIVE"
    fi
}

# Create status directory if it doesn't exist
mkdir -p "$STATUSFILE_PATH"

case "$ACTION" in
    --toggle)
        toggle_popup
        get_status
        ;;
    --show)
        show_popup
        get_status
        ;;
    --hide)
        hide_popup
        get_status
        ;;
    --launch)
        launch_popup
        get_status
        ;;
    --status|*)
        get_status
        ;;
esac
#
# #!/bin/bash
#
# # Universal Popup Manager Script
# # Usage: ./popup-manager.sh POPUP_NAME [--toggle|--show|--hide|--status]
#
# POPUP_NAME="$1"
# ACTION="${2:-status}"
# STATUSFILE_PATH="$HOME/.config/polybar/blocks/scripts/"
# STATUSFILE_PREFIX=".popup."
# STATUSFILE="$STATUSFILE_PATH$STATUSFILE_PREFIX$POPUP_NAME"
#
# # Icons for different states (using feather icons like your config)
# case "$POPUP_NAME" in
#     "bluetooth")
#         POPUP_ICON_ACTIVE=""  # Active bluetooth icon  
#         POPUP_ICON_INACTIVE=""  # Inactive bluetooth icon
#         ;;
#     "sysinfo")
#         POPUP_ICON_ACTIVE=""  # Active system icon
#         POPUP_ICON_INACTIVE=""  # Inactive system icon
#         ;;
#     "general")
#         POPUP_ICON_ACTIVE=""  # Active system icon
#         POPUP_ICON_INACTIVE=""  # Inactive system icon
#         ;;
#     "tray")
#         POPUP_ICON_ACTIVE=""  # Active tray icon  
#         POPUP_ICON_INACTIVE=""  # Inactive tray icon
#         ;;
#     *)
#         POPUP_ICON_ACTIVE=""  # Default active
#         POPUP_ICON_INACTIVE=""  # Default inactive
#         ;;
# esac
#
# function get_popup_pid() {
#     ps -ef | grep "polybar.*popup_$POPUP_NAME" | grep -v grep | awk '{print $2}' | head -1
# }
#
# function launch_popup() {
#     # Kill existing instance first
#     local existing_pid=$(get_popup_pid)
#     if [ ! -z "$existing_pid" ]; then
#         kill "$existing_pid" 2>/dev/null
#         sleep 0.1
#     fi
#
#     # Launch new popup instance with the main config
#     polybar -q "popup_$POPUP_NAME" -c "$HOME/.config/polybar/blocks/config.ini" &
#     sleep 0.2
#
#     # Mark as active
#     touch "$STATUSFILE"
# }
#
# function hide_popup() {
#     local popup_pid=$(get_popup_pid)
#     if [ ! -z "$popup_pid" ]; then
#         polybar-msg -p "$popup_pid" cmd hide 2>/dev/null
#         rm -f "$STATUSFILE"
#     fi
# }
#
# function show_popup() {
#     local popup_pid=$(get_popup_pid)
#     if [ ! -z "$popup_pid" ]; then
#         polybar-msg -p "$popup_pid" cmd show 2>/dev/null
#         touch "$STATUSFILE"
#     else
#         launch_popup
#     fi
# }
#
# function toggle_popup() {
#     if [ -f "$STATUSFILE" ]; then
#         hide_popup
#     else
#         show_popup
#     fi
# }
#
# function get_status() {
#     if [ -f "$STATUSFILE" ]; then
#         echo "$POPUP_ICON_ACTIVE"
#     else
#         echo "$POPUP_ICON_INACTIVE"
#     fi
# }
#
# # Create status directory if it doesn't exist
# mkdir -p "$STATUSFILE_PATH"
#
# case "$ACTION" in
#     --toggle)
#         toggle_popup
#         get_status
#         ;;
#     --show)
#         show_popup
#         get_status
#         ;;
#     --hide)
#         hide_popup
#         get_status
#         ;;
#     --launch)
#         launch_popup
#         get_status
#         ;;
#     --status|*)
#         get_status
#         ;;
# esac
