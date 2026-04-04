#!/usr/bin/env bash

METHOD="randr"
STATE_FILE="/tmp/gammastep_state_${USER}"

if [ -f "$STATE_FILE" ]; then
    echo "On"
else
    echo "Off"
fi
