#!/bin/bash
# Rofi wallpaper selector with feh and pywal integration
# WALLPAPERS PATH
wallDIR="$HOME/Pictures"
WORKSPACE_COLORS_SCRIPT="$HOME/.config/scripts/workspace-colors.sh"

# Available backends for pywal
BACKENDS="wal\ncolorthief\ncolorz\nhaishoku\nmodern_colorthief"

# Retrieve image files using null delimiter to handle spaces in filenames
mapfile -d '' PICS < <(find "${wallDIR}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) -print0)
RANDOM_PIC="${PICS[$((RANDOM % ${#PICS[@]}))]}"
RANDOM_PIC_NAME=". random"

# Rofi command
rofi_command="rofi -i -show -dmenu -config ~/.config/rofi/config-wallpaper.rasi"

# Function to select backend
select_backend() {
    BACKEND=$(echo -e "$BACKENDS" | rofi -dmenu -i -config ~/.config/rofi/config-compact.rasi -p "Select color backend: ")
    if [ -z "$BACKEND" ]; then
        echo "wal"  # default backend
    else
        echo "$BACKEND"
    fi
}

# Function to setup rofi wallpaper symlink (integrated from Refresh.sh)
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

# Function to set wallpaper with feh and apply colors with wal
set_wallpaper() {
    local wallpaper_path="$1"
    local backend="${2:-wal}"
    
    echo "Setting wallpaper: $wallpaper_path"
    echo "Using backend: $backend"
    
    # Set wallpaper with feh
    feh --bg-fill "$wallpaper_path"
    
    # Generate colors with pywal
    if [ -f "$WORKSPACE_COLORS_SCRIPT" ]; then
        wal -i "$wallpaper_path" --backend "$backend" -o "$WORKSPACE_COLORS_SCRIPT"
        # uncoment this line to hard set wallpapers
        feh --bg-scale ~/Pictures/1190404.jpg ~/Pictures/1351901.png
    else
        wal -i "$wallpaper_path" --backend "$backend"
        # uncoment this line to hard set wallpapers
        feh --bg-scale ~/Pictures/1190404.jpg ~/Pictures/1351901.png
    fi
    
    # Setup rofi wallpaper symlink (integrated refresh functionality)
    setup_rofi_wallpaper "$wallpaper_path"
    
    echo "Wallpaper and colors applied successfully"
    # uncoment this line to hard set wallpapers
    feh --bg-scale ~/Pictures/1190404.jpg ~/Pictures/1351901.png
}

# Sorting Wallpapers for menu
menu() {
  # Sort the PICS array
  IFS=$'\n' sorted_options=($(sort <<<"${PICS[*]}"))
  
  # Place ". random" at the beginning with the random picture as an icon
  printf "%s\x00icon\x1f%s\n" "$RANDOM_PIC_NAME" "$RANDOM_PIC"
  
  for pic_path in "${sorted_options[@]}"; do
    pic_name=$(basename "$pic_path")
    
    # Displaying all images with icons for preview
    if [[ ! "$pic_name" =~ \.gif$ ]]; then
      printf "%s\x00icon\x1f%s\n" "$(echo "$pic_name" | cut -d. -f1)" "$pic_path"
    else
      # For GIFs, still show with icon but note it's animated
      printf "%s (animated)\x00icon\x1f%s\n" "$(echo "$pic_name" | cut -d. -f1)" "$pic_path"
    fi
  done
}

# Main function
main() {
  choice=$(menu | $rofi_command)
  
  # Trim any potential whitespace or hidden characters
  choice=$(echo "$choice" | xargs)
  RANDOM_PIC_NAME=$(echo "$RANDOM_PIC_NAME" | xargs)
  
  # No choice case
  if [[ -z "$choice" ]]; then
    echo "No choice selected. Exiting."
    exit 0
  fi
  
  # Get backend selection
  BACKEND=$(select_backend)
  
  # Random choice case
  if [[ "$choice" == "$RANDOM_PIC_NAME" ]]; then
    echo "Random wallpaper selected: $RANDOM_PIC"
    set_wallpaper "$RANDOM_PIC" "$BACKEND"
    exit 0
  fi
  
  # Find the selected wallpaper file
  selected_pic=""
  choice_clean=$(echo "$choice" | sed 's/ (animated)$//')  # Remove animated suffix
  
  for pic_path in "${PICS[@]}"; do
    filename=$(basename "$pic_path")
    filename_no_ext=$(echo "$filename" | cut -d. -f1)
    
    if [[ "$filename_no_ext" == "$choice_clean" ]] || [[ "$filename" == "$choice"* ]]; then
      selected_pic="$pic_path"
      break
    fi
  done
  
  if [[ -n "$selected_pic" ]]; then
    echo "Selected wallpaper: $selected_pic"
    set_wallpaper "$selected_pic" "$BACKEND"
  else
    echo "Image not found: $choice"
    exit 1
  fi
}

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

# Run main function
main

echo "Wallpaper setup complete!"
