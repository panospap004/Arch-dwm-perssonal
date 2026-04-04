#!/usr/bin/env bash

METHOD="randr"
TEMP=5000
STATE_FILE="/tmp/gammastep_state_${USER}"

# Check if gammastep is "on" based on state file
if [ -f "$STATE_FILE" ]; then
    # Gammastep is on, turn it off by resetting to default
    echo "Turning off gammastep"
    gammastep -O 6500 -m "${METHOD}" -P >/dev/null 2>&1
    rm -f "$STATE_FILE"
else
    # Gammastep is off, turn it on
    echo "Turning on gammastep (temp ${TEMP})"
    gammastep -O "${TEMP}" -m "${METHOD}" -P >/dev/null 2>&1
    echo "on" > "$STATE_FILE"
fi
