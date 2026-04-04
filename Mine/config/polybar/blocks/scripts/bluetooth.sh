#!/bin/bash

# Bluetooth status script for Polybar

if command -v bluetoothctl &> /dev/null; then
    if bluetoothctl show | grep -q "Powered: yes"; then
        connected_devices=$(bluetoothctl devices | wc -l)
        if [ $connected_devices -gt 0 ]; then
            echo "󰂱 $connected_devices"
        else
            echo "󰂯"
        fi
    else
        echo "󰂲"
    fi
else
    echo ""
fi
