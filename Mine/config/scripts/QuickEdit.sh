#!/bin/bash
# Works
# Rofi menu for Quick Edit/View of Settings (SUPER+shift+E)

# Define preferred text editor and terminal
edit=${EDITOR:-nvim}
tty=kitty

# Paths to configuration directories
DwmConfigs="$HOME/.config/dwm"
Configs="$HOME/.config/"

# Function to display the menu options
menu() {
    cat <<EOF
1. View / Edit  dwm-config.h
2. View / Edit  dmenu-config.h
3. View / Edit  slock-config.h
4. View / Edit  polybar-folder
5. View / Edit  pywal
6. View / Edit  rofi-folder
7. View / Edit  scripts-folder
8. View / Edit  mpd
9. View / Edit  picom
10. View / Edit  dunst
11. View / Edit  config-folder
12. View / Edit  nvim-folder
13. View / Edit  emacs-folder
EOF
}

# Main function to handle menu selection
main() {
    choice=$(menu | rofi -i -dmenu -config ~/.config/rofi/config-compact.rasi | cut -d. -f1)
    
    # Map choices to corresponding files
    case $choice in
        1) file="$DwmConfigs/config.h" ;;
        2) file="$Configs/dmenu/config.h" ;;
        3) file="$Configs/slock/config.h" ;;
        4) file="$Configs/polybar/" ;;
        5) file="$Configs/wal" ;;
        6) file="$Configs/rofi/" ;;
        7) file="$Configs/scripts/" ;;
        8) file="$Configs/mpd/mpd.conf" ;;
        9) file="$Configs/picom.conf" ;;
        10) file="$Configs/wal/templates/dunstrc" ;;
        11) file="$Configs" ;;
        12) file="$Configs/nvim" ;;
        13) file="$Configs/emacs" ;;
        *) return ;;  # Do nothing for invalid choices
    esac

    # Open the selected file in the terminal with the text editor
    $tty -e $edit "$file"
}

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

main
