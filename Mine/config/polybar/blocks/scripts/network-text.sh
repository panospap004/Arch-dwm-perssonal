#!/bin/bash

if ip link show eno1 | grep -q "state UP"; then
    echo "Wired"
elif ip link show wlan0 | grep -q "state UP"; then
    SSID=$(iw dev wlan0 info | grep ssid | awk '{print $2}')
    echo "${SSID:-WiFi}"
else
    echo "Offline"
fi
