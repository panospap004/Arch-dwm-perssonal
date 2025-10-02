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
            wal -i "$FOLDER" --backend "$BACKEND" -o $SCRIPT
            setup_rofi_wallpaper "$RANDOM_WALL"
            # uncoment this line to hard set wallpapers
            feh --bg-scale ~/Pictures/1190404.jpg ~/Pictures/1351901.png
            ;;
        *) 
            # Handle both full path (from nsxiv) and filename (from dmenu)
            if [[ "$CHOICE" == /* ]]; then
                # Full path from nsxiv
                wal -i "$CHOICE" --backend "$BACKEND" -o $SCRIPT
                setup_rofi_wallpaper "$CHOICE"
                # uncoment this line to hard set wallpapers
                feh --bg-scale ~/Pictures/1190404.jpg ~/Pictures/1351901.png
            elif [[ "$CHOICE" == *.* ]]; then
                # Filename only from dmenu
                wal -i "$FOLDER/$CHOICE" --backend "$BACKEND" -o $SCRIPT
                setup_rofi_wallpaper "$FOLDER/$CHOICE"
                # uncoment this line to hard set wallpapers
                feh --bg-scale ~/Pictures/1190404.jpg ~/Pictures/1351901.png
            else
                exit 0
            fi
            ;;
    esac
}

# Function to handle single argument with backend selection
single_arg_with_backend() {
    BACKEND=$(select_backend)
    wal -i "$1" --backend "$BACKEND" -o $SCRIPT
    setup_rofi_wallpaper "$1"
    # uncoment this line to hard set wallpapers
    feh --bg-scale ~/Pictures/1190404.jpg ~/Pictures/1351901.png
}

# Function to handle two arguments with backend selection
two_args_with_backend() {
    BACKEND=$(select_backend)
    wal -i "$1" --theme "$2" --backend "$BACKEND" -o $SCRIPT
    setup_rofi_wallpaper "$1"
    # uncoment this line to hard set wallpapers
    feh --bg-scale ~/Pictures/1190404.jpg ~/Pictures/1351901.png
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
        wal -i "$1" --theme "$2" --backend "$3" -o $SCRIPT
        setup_rofi_wallpaper "$1"
        # uncoment this line to hard set wallpapers
        feh --bg-scale ~/Pictures/1190404.jpg ~/Pictures/1351901.png
        ;;
    *) 
        exit 0 ;;
esac

# alternative using sxiv
# #!/usr/bin/env bash
# # Enhanced wallpaper picker menu for use with pywal - uses sxiv for preview when available
# # Includes backend selection for color generation and rofi integration
#
# FOLDER=~/Pictures/ # wallpaper folder
# SCRIPT=~/.config/scripts/workspace-colors.sh # script to run after wal for refreshing programs, etc.
#
# # Available backends for pywal
# BACKENDS="wal\nmodern_colorthief\ncolorthief\nhaishoku\ncolorz"
#
# # Function to select backend
# select_backend() {
#     BACKEND=$(echo -e "$BACKENDS" | dmenu -noi -l 5 -g 2 -p "Select color backend: ")
#     if [ -z "$BACKEND" ]; then
#         exit 0
#     fi
#     echo "$BACKEND"
# }
#
# # Function to setup rofi wallpaper symlink
# setup_rofi_wallpaper() {
#     local wallpaper_path="$1"
#
#     # Create rofi config directory if it doesn't exist
#     mkdir -p ~/.config/rofi/
#
#     # Create symlink for rofi wallpaper access
#     if [ -f "$wallpaper_path" ]; then
#         ln -sf "$wallpaper_path" ~/.config/rofi/.current_wallpaper
#         echo "Rofi wallpaper symlink created: $wallpaper_path"
#     fi
# }
#
# # Function to set wallpaper with pywal
# set_wallpaper() {
#     local wallpaper_path="$1"
#     local backend="$2"
#     local theme="$3"
#
#     if [ -n "$theme" ]; then
#         wal -i "$wallpaper_path" --theme "$theme" --backend "$backend" -o "$SCRIPT"
#     else
#         wal -i "$wallpaper_path" --backend "$backend" -o "$SCRIPT"
#     fi
#
#     setup_rofi_wallpaper "$wallpaper_path"
#     echo "Wallpaper set: $wallpaper_path"
# }
#
# # Main menu function
# menu() {
#     # Check if wallpaper directory exists
#     if [ ! -d "$FOLDER" ]; then
#         echo "Error: Wallpaper directory not found: $FOLDER"
#         exit 1
#     fi
#
#     # Check if there are any image files
#     if ! find "$FOLDER" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.gif" \) -print -quit | grep -q .; then
#         echo "Error: No image files found in $FOLDER"
#         exit 1
#     fi
#
#     # First, ask what they want to do
#     ACTION=$(printf "Set wallpaper\nRandom wallpaper\nExit" | dmenu -l 3 -g 2 -p "What would you like to do?")
#
#     case "$ACTION" in
#         "Set wallpaper")
#             # Use sxiv for wallpaper selection if available
#             if command -v sxiv >/dev/null 2>&1; then
#                 echo "Opening sxiv image browser..."
#                 notify-send "Instructions: Use arrow keys or hjkl to navigate, press 'm' to mark the image you want, then 'q' to quit and use marked images"
#                 CHOICE=$(sxiv -t -o "${FOLDER}")
#
#                 if [ -z "$CHOICE" ]; then
#                     echo "No wallpaper selected."
#                     exit 0
#                 fi
#             else
#                 # Fallback to dmenu list if sxiv not available
#                 echo "sxiv not found, using dmenu fallback..."
#                 CHOICE=$(find "$FOLDER" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.gif" \) -exec basename {} \; | sort | dmenu -l 15 -g 2 -i -p "Wallpaper: ")
#
#                 if [ -z "$CHOICE" ]; then
#                     echo "No wallpaper selected."
#                     exit 0
#                 fi
#
#                 # Convert basename back to full path for dmenu selection
#                 CHOICE="$FOLDER/$CHOICE"
#             fi
#
#             # Get backend selection
#             BACKEND=$(select_backend)
#             if [ -z "$BACKEND" ]; then
#                 exit 0
#             fi
#
#             # Set the wallpaper
#             set_wallpaper "$CHOICE" "$BACKEND"
#             ;;
#
#         "Random wallpaper")
#             # Get random wallpaper
#             RANDOM_WALL=$(find "$FOLDER" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.gif" \) | shuf -n 1)
#
#             if [ -z "$RANDOM_WALL" ]; then
#                 echo "No images found for random selection."
#                 exit 1
#             fi
#
#             # Get backend selection
#             BACKEND=$(select_backend)
#             if [ -z "$BACKEND" ]; then
#                 exit 0
#             fi
#
#             # Set random wallpaper
#             set_wallpaper "$RANDOM_WALL" "$BACKEND"
#             ;;
#
#         "Exit"|"")
#             echo "Cancelled."
#             exit 0
#             ;;
#
#         *)
#             echo "Invalid selection."
#             exit 1
#             ;;
#     esac
# }
#
# # Function to handle single argument with backend selection
# single_arg_with_backend() {
#     BACKEND=$(select_backend)
#     if [ -n "$BACKEND" ]; then
#         set_wallpaper "$1" "$BACKEND"
#     fi
# }
#
# # Function to handle two arguments with backend selection
# two_args_with_backend() {
#     BACKEND=$(select_backend)
#     if [ -n "$BACKEND" ]; then
#         set_wallpaper "$1" "$BACKEND" "$2"
#     fi
# }
#
# # Check dependencies
# if ! command -v wal >/dev/null 2>&1; then
#     echo "Error: pywal is required but not installed"
#     exit 1
# fi
#
# if ! command -v dmenu >/dev/null 2>&1; then
#     echo "Error: dmenu is required but not installed"
#     exit 1
# fi
#
# # If given arguments:
# # First argument will be used by pywal as wallpaper/dir path
# # Second will be used as theme (use wal --theme to view built-in themes)
# # Third argument can be used to specify backend directly
# case "$#" in
#     0) 
#         menu ;;
#     1) 
#         if [ -f "$1" ] || [ -d "$1" ]; then
#             single_arg_with_backend "$1"
#         else
#             echo "Error: File or directory not found: $1"
#             exit 1
#         fi
#         ;;
#     2) 
#         if [ -f "$1" ] || [ -d "$1" ]; then
#             two_args_with_backend "$1" "$2"
#         else
#             echo "Error: File or directory not found: $1"
#             exit 1
#         fi
#         ;;
#     3)
#         if [ -f "$1" ] || [ -d "$1" ]; then
#             set_wallpaper "$1" "$3" "$2"
#         else
#             echo "Error: File or directory not found: $1"
#             exit 1
#         fi
#         ;;
#     *) 
#         echo "Usage: $0 [wallpaper_path] [theme] [backend]"
#         exit 1
#         ;;
# esac

