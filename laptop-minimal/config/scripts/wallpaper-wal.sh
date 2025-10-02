#!/usr/bin/env bash
# WORKS needs nsxiv
# Enhanced wallpaper picker menu for use with pywal - uses nsxiv if installed, otherwise uses dmenu
# Includes backend selection for color generation and rofi integration
FOLDER=~/Pictures/ # wallpaper folder
SCRIPT=~/.config/scripts/workspace-colors.sh # script to run after wal for refreshing programs, etc.

# Available backends for pywal
BACKENDS="wal\nmodern_colorthief\ncolorthief\nhaishoku\ncolorz"

# Function to select backend
select_backend() {
    BACKEND=$(echo -e "$BACKENDS" | dmenu -noi -l 5 -g 2 -p "Select color backend: ")
    if [ -z "$BACKEND" ]; then
        exit 0
    fi
    echo "$BACKEND"
}

# Function to setup rofi wallpaper symlink
setup_rofi_wallpaper() {
    local wallpaper_path="$1"
    # Create rofi config directory if it doesn't exist
    mkdir -p ~/.config/rofi/
    # Create symlink for rofi wallpaper access
    if [ -f "$wallpaper_path" ]; then
        ln -sf "$wallpaper_path" ~/.config/rofi/.current_wallpaper
        echo "Rofi wallpaper symlink created: $wallpaper_path"
    fi
}

# Main menu function
menu() {
    if command -v nsxiv >/dev/null; then 
      notify-send "Instructions: Use arrow keys or hjkl to navigate, press 'm' to mark the image you want, then 'q' to quit and use marked images, or just q to cancel"
        # Create a temporary file to store marked images
        MARKED_FILE=$(mktemp)
        
        # Run nsxiv with marking enabled - marked files will be written to stdout when quitting
        # The -o flag outputs selected/marked files
        nsxiv -otb "$FOLDER"/* > "$MARKED_FILE" 2>/dev/null
        
        # Check if any files were marked/selected
        if [ -s "$MARKED_FILE" ]; then
            # Get the first marked/selected file
            CHOICE=$(head -n 1 "$MARKED_FILE")
        else
            # No selection made, exit
            CHOICE=""
        fi
        
        rm -f "$MARKED_FILE"
    else 
        CHOICE=$(echo -e "Random\n$(command ls -v $FOLDER)" | dmenu -l 15 -g 2 -i -p "Wallpaper: ")
    fi
    
    if [ -z "$CHOICE" ]; then
        exit 0
    fi
    
    # Get backend selection
    BACKEND=$(select_backend)
    
    case $CHOICE in
        Random) 
            # Get random wallpaper for symlink
            RANDOM_WALL=$(find "$FOLDER" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | shuf -n 1)
            wal -i "$FOLDER" --backend "$BACKEND" -n -o $SCRIPT
            setup_rofi_wallpaper "$RANDOM_WALL"
            ;;
        *) 
            # Handle both full path (from nsxiv) and filename (from dmenu)
            if [[ "$CHOICE" == /* ]]; then
                # Full path from nsxiv
                wal -i "$CHOICE" --backend "$BACKEND" -n -o $SCRIPT
                setup_rofi_wallpaper "$CHOICE"
            elif [[ "$CHOICE" == *.* ]]; then
                # Filename only from dmenu
                wal -i "$FOLDER/$CHOICE" --backend "$BACKEND" -n -o $SCRIPT
                setup_rofi_wallpaper "$FOLDER/$CHOICE"
            else
                exit 0
            fi
            ;;
    esac
}

# Function to handle single argument with backend selection
single_arg_with_backend() {
    BACKEND=$(select_backend)
    wal -i "$1" --backend "$BACKEND" -n -o $SCRIPT
    setup_rofi_wallpaper "$1"
}

# Function to handle two arguments with backend selection
two_args_with_backend() {
    BACKEND=$(select_backend)
    wal -i "$1" --theme "$2" --backend "$BACKEND" -n -o $SCRIPT
    setup_rofi_wallpaper "$1"
}

# If given arguments:
# First argument will be used by pywal as wallpaper/dir path
# Second will be used as theme (use wal --theme to view built-in themes)
# Third argument can be used to specify backend directly
case "$#" in
    0) 
        menu ;;
    1) 
        # Ask for backend selection
        single_arg_with_backend "$1" ;;
    2) 
        # Ask for backend selection with theme
        two_args_with_backend "$1" "$2" ;;
    3)
        # Direct backend specification
        wal -i "$1" --theme "$2" --backend "$3" -n -o $SCRIPT
        setup_rofi_wallpaper "$1"
        ;;
    *) 
        exit 0 ;;
esac
