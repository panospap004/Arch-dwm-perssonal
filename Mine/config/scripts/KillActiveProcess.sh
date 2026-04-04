#!/bin/bash
# works

# Get the window ID of the currently focused window
window_id=$(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $5}')

# Check if a window ID was found
if [ -n "$window_id" ]; then
    # Get the PID of the process owning the window
    pid=$(xprop -id "$window_id" | awk '/_NET_WM_PID\(CARDINAL\)/{print $3}')

    # Check if a PID was found
    if [ -n "$pid" ]; then
        # Kill the process
        kill "$pid"
    else
        echo "No PID found for window ID $window_id"
    fi
else
    echo "No active window found"
fi
