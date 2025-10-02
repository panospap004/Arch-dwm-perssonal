#!/bin/sh

# Cleanup function
cleanup() {
    pkill -f polybar
    pkill -f mpd
    exit 0
}
trap cleanup TERM INT

# Background setup
# wal -R
# if you want to use hard set wallpapers on its monitor uncomend this line and put you wallpapers (you need to do the same in 2 scripts in multiple lines the scripts are wallpaper-menu.sh, Wallpaper-select.sh)
# feh --bg-scale ~/Pictures/1190404.jpg ~/Pictures/1351901.png

# # Background setup
# # feh --bg-scale ~/Pictures/a.png # if you are using a specific wallpaper
# wal -R # if you are using pywal for theme and wallpaper

# Start MPD
mpd ~/.config/mpd/mpd.conf &

# Disable the annoying x11 bell sound
xset -b &

# Keyboard layout
setxkbmap -layout us,gr -option 'grp:alt_shift_toggle' 
xset r rate 300 50

# Start xautolock
xautolock -time 10 -locker "slock -d" -detectsleep &
# # time in minutes
#
# # disable
# # you can run: xautolock -disable
#
# # or toggle
# # xautolock -toggle

# Other services
picom &
libinput-gestures-setup restart &
greenclip daemon &

# Apply your arandr layout if you have one saved
# Uncomment this line and set the correct path:
if type "xrandr" > /dev/null; then
	~/.screenlayout/default.sh &
fi
# Background setup
wal -R
# if you want to use hard set wallpapers on its monitor uncomend this line and put you wallpapers (you need to do the same in 2 scripts in multiple lines the scripts are wallpaper-menu.sh, Wallpaper-select.sh)
feh --bg-scale ~/Pictures/1190404.jpg ~/Pictures/1351901.png

# Wait a moment for monitors to be ready
sleep 1

# Function to start polybar
start_polybar() {
    # Kill any existing polybar instances
    pkill -f polybar 2>/dev/null
    sleep 0.5
    
    # Start polybar on all monitors
    if type "xrandr" > /dev/null; then
        for monitor in $(xrandr --query | grep " connected" | cut -d" " -f1); do
            echo "Starting polybar on $monitor"
            MONITOR=$monitor polybar -q main -c "$HOME/.config/polybar/blocks/config.ini" &
        done
    else
        polybar -q main -c "$HOME/.config/polybar/blocks/config.ini" &
    fi


#     # Method 2: Manual monitor specification (uncomment and modify as needed)
#     # MONITOR=DP-1 ~/.config/polybar/launch.sh &
#     # MONITOR=HDMI-A-1 ~/.config/polybar/launch.sh &
#     # MONITOR=eDP-1 ~/.config/polybar/launch.sh &
    
    # Wait for main bars to start
    sleep 1
    
    # Launch popup bars
    polybar -q popup_bluetooth -c "$HOME/.config/polybar/blocks/config.ini" &
    polybar -q popup_sysinfo -c "$HOME/.config/polybar/blocks/config.ini" &
    polybar -q popup_general -c "$HOME/.config/polybar/blocks/config.ini" &
    polybar -q popup_tray -c "$HOME/.config/polybar/blocks/config.ini" &
    
    # Hide all popups initially
    sleep 0.5
    "$HOME/.config/polybar/blocks/scripts/popup-manager.sh" bluetooth --hide
    "$HOME/.config/polybar/blocks/scripts/popup-manager.sh" sysinfo --hide
    "$HOME/.config/polybar/blocks/scripts/popup-manager.sh" general --hide
    "$HOME/.config/polybar/blocks/scripts/popup-manager.sh" tray --hide
}

# Start polybar initially
start_polybar

# DWM loop with polybar management
while true; do
    # Start DWM and capture its exit code
    dwm 2> ~/.dwm.log
    exit_code=$?
    
    # Log restart
    echo "DWM exited with code $exit_code at $(date), restarting..." >> ~/.dwm.log
    
    # Restart polybar
    start_polybar
    sleep 1
done

# Cleanup on exit
cleanup
