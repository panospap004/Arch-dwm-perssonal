#!/usr/bin/env bash

# Check if Bluetooth is powered on
POWERED=$(bluetoothctl show 2>/dev/null | grep "Powered: yes")

if [ -z "$POWERED" ]; then
    # Bluetooth is disabled
    echo "󰂲"
    exit 0
fi

# Bluetooth is enabled, check for connected devices
CONNECTED=$(bluetoothctl devices Connected 2>/dev/null)

if [ -z "$CONNECTED" ]; then
    # Enabled but nothing connected
    echo "󰂯"
else
    # Enabled and something is connected
    echo "󰂱"
fi
