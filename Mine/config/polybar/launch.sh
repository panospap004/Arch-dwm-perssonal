# #!/usr/bin/env bash
#
# # Add this script to your wm startup file.
#
# DIR="$HOME/.config/polybar/"
#
# # Terminate already running bar instances
# killall -q polybar
#
# # Wait until the processes have been shut down
# while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
#
# # Launch the bar
# polybar -q main -c "$DIR"/config.ini &

# #!/usr/bin/env bash
#
# # Add this script to your wm startup file
# #
# DIR="$HOME/.config/polybar/blocks"
#
# # Terminate already running bar instances
# killall -q polybar
#
# # Wait until the processes have been shut down
# while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
#
# # Launch the main bar
# polybar -q main -c "$DIR"/config.ini &
#
# # Wait for main bar to start
# sleep 1
#
# # Launch popup bars using the same config file  
# polybar -q popup_bluetooth -c "$DIR"/config.ini &
# polybar -q popup_sysinfo -c "$DIR"/config.ini &
# polybar -q popup_general -c "$DIR"/config.ini &
# polybar -q popup_tray -c "$DIR"/config.ini &
#
# # Hide all popups initially
# sleep 0.5
# "$DIR"/scripts/popup-manager.sh bluetooth --hide
# "$DIR"/scripts/popup-manager.sh sysinfo --hide
# "$DIR"/scripts/popup-manager.sh general --hide
# "$DIR"/scripts/popup-manager.sh tray --hide
#
#!/usr/bin/env bash

DIR="$HOME/.config/polybar/blocks"

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch the main bar on all monitors
if type "xrandr" > /dev/null; then
    for monitor in $(xrandr --query | grep " connected" | cut -d" " -f1); do
        MONITOR=$monitor polybar -q main -c "$DIR"/config.ini &
    done
else
    # Fallback if xrandr not available
    polybar -q main -c "$DIR"/config.ini &
fi

# Wait for main bars to start
sleep 1

# Launch popup bars (these are monitor-independent)
polybar -q popup_bluetooth -c "$DIR"/config.ini &
polybar -q popup_sysinfo -c "$DIR"/config.ini &
polybar -q popup_general -c "$DIR"/config.ini &
polybar -q popup_tray -c "$DIR"/config.ini &

# Hide all popups initially
sleep 0.5
"$DIR"/scripts/popup-manager.sh bluetooth --hide
"$DIR"/scripts/popup-manager.sh sysinfo --hide
"$DIR"/scripts/popup-manager.sh general --hide
"$DIR"/scripts/popup-manager.sh tray --hide
