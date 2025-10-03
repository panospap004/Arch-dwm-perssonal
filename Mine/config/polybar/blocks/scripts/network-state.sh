#!/bin/bash

# if you get an error on this script check ip link show for the link/ether line and and change the enp2s0 to what that line shows eno1 or eth0 etc
# Check wired connection first
if ip link show enp2s0 | grep -q "state UP"; then
    echo "wired"
    exit 0
fi

# Check wireless connection
if ip link show wlan0 | grep -q "state UP"; then
    echo "wifi"
    exit 0
fi

# No connection
echo "disconnected"

# #!/bin/bash
#
# # Check wired connection first
# if ip link show eno1 | grep -q "state UP"; then
#     echo " Wired"
#     exit 0
# fi
#
# # Check wireless connection
# if ip link show wlan0 | grep -q "state UP"; then
#     SSID=$(iw dev wlan0 info | grep ssid | awk '{print $2}')
#     if [ -n "$SSID" ]; then
#         echo "  $SSID"
#     else
#         echo "󰤨 WiFi"
#     fi
#     exit 0
# fi
#
# # No connection
# echo "󰤭 Offline"
