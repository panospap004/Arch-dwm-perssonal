#!/usr/bin/env bash

# Get the active window title
TITLE=$(xdotool getactivewindow getwindowname 2>/dev/null)

# If no window is active or title is empty, show "Desktop"
if [ -z "$TITLE" ]; then
    echo "Desktop"
else
    echo "$TITLE"
fi
