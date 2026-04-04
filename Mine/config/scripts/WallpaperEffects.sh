#!/bin/bash
# WORKS
# Enhanced rofi wallpaper selector with feh, pywal, and ImageMagick effects
# WALLPAPERS PATH
wallDIR="$HOME/Pictures"
WORKSPACE_COLORS_SCRIPT="$HOME/.config/scripts/workspace-colors.sh"
EFFECTS_DIR=~/.cache/wallpaper_effects/ # directory to store processed wallpapers

# Create effects directory if it doesn't exist
mkdir -p "$EFFECTS_DIR"

# Available backends for pywal
BACKENDS="wal\ncolorthief\ncolorz\nhaishoku\nmodern_colorthief"

# ImageMagick effects - using only standard/guaranteed operations
declare -A effects=(
    # ["No Effects"]="no-effects"
    ["Black and White"]="magick INPUT -colorspace gray -sigmoidal-contrast 10,40% OUTPUT"
    ["Blurred"]="magick INPUT -blur 0x10 OUTPUT"
    ["Charcoal"]="magick INPUT -charcoal 2 OUTPUT"
    ["Edge Detect"]="magick INPUT -edge 1 OUTPUT"
    ["Emboss"]="magick INPUT -emboss 2 OUTPUT"
    # ["Frame Raised"]="magick INPUT -raise 8x8 OUTPUT"
    # ["Frame Sunk"]="magick INPUT -raise 8x8 OUTPUT"
    ["Negate"]="magick INPUT -negate OUTPUT"
    ["Posterize"]="magick INPUT -posterize 8 OUTPUT"
    ["Sepia Tone"]="magick INPUT -sepia-tone 80% OUTPUT"
    ["Solarize"]="magick INPUT -solarize 50% OUTPUT"
    ["Sharpen"]="magick INPUT -unsharp 2x1.4+0.5+0 OUTPUT"
    # ["Enhance"]="magick INPUT -enhance OUTPUT"
    # ["Normalize"]="magick INPUT -normalize OUTPUT"
    ["Contrast"]="magick INPUT -brightness-contrast 0x25 OUTPUT"
    ["Brightness Up"]="magick INPUT -modulate 150,100,100 OUTPUT"
    ["Brightness Down"]="magick INPUT -modulate 70,100,100 OUTPUT"
    ["Saturation Up"]="magick INPUT -modulate 100,150,100 OUTPUT"
    ["Saturation Down"]="magick INPUT -modulate 100,50,100 OUTPUT"
    ["Vintage Look"]="magick INPUT -modulate 120,70,100 -fill '#704214' -colorize 10% OUTPUT"
    ["Cool Tone"]="magick INPUT -modulate 100,120,100 -fill '#0066cc' -colorize 12% OUTPUT"
    ["Warm Tone"]="magick INPUT -modulate 100,120,100 -fill '#cc6600' -colorize 10% OUTPUT"
    ["High Contrast"]="magick INPUT -brightness-contrast 0x50 OUTPUT"
    ["Soft Focus"]="magick INPUT -blur 0x3 OUTPUT"
)

# Retrieve image files using null delimiter to handle spaces in filenames
mapfile -d '' PICS < <(find "${wallDIR}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) -print0)
RANDOM_PIC="${PICS[$((RANDOM % ${#PICS[@]}))]}"
RANDOM_PIC_NAME=". random"

# Rofi command
rofi_command="rofi -i -show -dmenu -config ~/.config/rofi/config-wallpaper.rasi"

# Function to select backend
select_backend() {
    BACKEND=$(echo -e "$BACKENDS" | rofi -dmenu -i -p "Select color backend: ")
    if [ -z "$BACKEND" ]; then
        echo "wal"  # default backend
    else
        echo "$BACKEND"
    fi
}

# Function to select effect
select_effect() {
    # Create effect list for rofi
    EFFECT_LIST=""
    for effect_name in "${!effects[@]}"; do
        if [ -z "$EFFECT_LIST" ]; then
            EFFECT_LIST="$effect_name"
        else
            EFFECT_LIST="$EFFECT_LIST\n$effect_name"
        fi
    done
    
    # Sort the effects list
    SELECTED_EFFECT=$(echo -e "$EFFECT_LIST" | sort | rofi -dmenu -i -p "Select wallpaper effect: ")
    if [ -z "$SELECTED_EFFECT" ]; then
        echo "No Effects"  # Default to no effects
    else
        echo "$SELECTED_EFFECT"
    fi
}

# Function to apply effect to wallpaper
apply_effect() {
    local wallpaper_current="$1"
    local effect_name="$2"
    local wallpaper_output="$3"
    
    if [ "$effect_name" == "No Effects" ]; then
        # Just copy the original
        cp "$wallpaper_current" "$wallpaper_output"
        echo "No effect applied"
        return 0
    fi
    
    # Get the command template for the selected effect
    local effect_command="${effects[$effect_name]}"
    
    if [ -z "$effect_command" ]; then
        echo "Unknown effect: $effect_name"
        cp "$wallpaper_current" "$wallpaper_output"
        return 1
    fi
    
    echo "Applying effect: $effect_name"
    echo "Input: $wallpaper_current"
    echo "Output: $wallpaper_output"
    
    # Replace INPUT and OUTPUT placeholders with actual paths - fix sed replacement order
    local final_command="$effect_command"
    final_command=$(echo "$final_command" | sed "s|INPUT|\"$wallpaper_current\"|g")
    final_command=$(echo "$final_command" | sed "s|OUTPUT|\"$wallpaper_output\"|g")
    
    echo "Running: $final_command"
    
    # Execute the ImageMagick command directly without eval to avoid shell interpretation issues
    bash -c "$final_command" 2>&1
    local exit_code=$?
    
    if [ $exit_code -eq 0 ] && [ -f "$wallpaper_output" ]; then
        echo "Effect '$effect_name' applied successfully"
        return 0
    else
        echo "Failed to apply effect '$effect_name' (exit code: $exit_code), using original wallpaper"
        cp "$wallpaper_current" "$wallpaper_output"
        return 1
    fi
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

# Function to set wallpaper with effects, feh and pywal
set_wallpaper() {
    local original_wallpaper="$1"
    local backend="$2"
    local effect_name="$3"
    local final_wallpaper="$original_wallpaper"

   # clear cache if not empty
    if [ "$(ls -A "$EFFECTS_DIR")" ]; then
        echo "Cache found in $EFFECTS_DIR, clearing..."
        rm -f "$EFFECTS_DIR"/*
    fi
    
    # Apply effect if not "No Effects"
    if [ "$effect_name" != "No Effects" ]; then
        # Create output filename based on original name and effect
        local basename=$(basename "$original_wallpaper")
        local name_no_ext="${basename%.*}"
        local extension="${basename##*.}"
        local effect_safe=$(echo "$effect_name" | tr ' &' '_' | tr -d '()[]{}!@#$%^*')        local processed_wallpaper="$EFFECTS_DIR/${name_no_ext}_${effect_safe}.${extension}"
        
        # Check if processed wallpaper already exists
        if [ -f "$processed_wallpaper" ]; then
            echo "Using cached processed wallpaper: $processed_wallpaper"
            final_wallpaper="$processed_wallpaper"
        else
            # Apply the effect
            if apply_effect "$original_wallpaper" "$effect_name" "$processed_wallpaper"; then
                final_wallpaper="$processed_wallpaper"
            else
                echo "Effect failed, using original wallpaper"
                final_wallpaper="$original_wallpaper"
            fi
        fi
    fi
    
    echo "Setting wallpaper: $final_wallpaper"
    echo "Using backend: $backend"
    
    # Set wallpaper with feh
    feh --bg-fill "$final_wallpaper"
    
    # Generate colors with pywal
    if [ -f "$WORKSPACE_COLORS_SCRIPT" ]; then
        wal -i "$final_wallpaper" --backend "$backend" -o "$WORKSPACE_COLORS_SCRIPT"
    else
        wal -i "$final_wallpaper" --backend "$backend"
    fi
    
    # Setup rofi wallpaper symlink
    setup_rofi_wallpaper "$final_wallpaper"
    
    echo "Wallpaper and colors applied successfully"
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
  
  # Get effect selection
  EFFECT=$(select_effect)
  
  # Random choice case
  if [[ "$choice" == "$RANDOM_PIC_NAME" ]]; then
    echo "Random wallpaper selected: $RANDOM_PIC"
    set_wallpaper "$RANDOM_PIC" "$BACKEND" "$EFFECT"
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
    set_wallpaper "$selected_pic" "$BACKEND" "$EFFECT"
  else
    echo "Image not found: $choice"
    exit 1
  fi
}

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

# Check if ImageMagick is installed
if ! command -v magick >/dev/null 2>&1; then
    echo "Warning: ImageMagick not found. Effects will not work."
    echo "Install with: sudo pacman -S imagemagick"
fi

# Run main function
main

echo "Wallpaper setup complete!"
