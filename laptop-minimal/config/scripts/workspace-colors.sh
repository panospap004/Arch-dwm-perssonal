#!/bin/bash
# WORKS
# Enhanced workspace colors script with rofi integration
# Save as ~/.config/scripts/workspace-colors.sh

# Define file_exists function
file_exists() {
    if [ -e "$1" ]; then
        return 0  # File exists
    else
        return 1  # File does not exist
    fi
}

# Function to setup rofi colors
setup_rofi_colors() {
    # Check if colors-rofi.rasi exists in wal cache
    if file_exists ~/.cache/wal/colors-rofi.rasi; then
        echo "Setting up rofi colors..."
        
        # Append rofi colors to Xresources
        echo "" >> ~/.Xresources
        echo "! Rofi Colors" >> ~/.Xresources
        cat ~/.cache/wal/colors-rofi.rasi >> ~/.Xresources
        
        # Also copy to rofi config directory for direct access
        mkdir -p ~/.config/rofi/
        cp ~/.cache/wal/colors-rofi.rasi ~/.config/rofi/colors.rasi
        
        echo "Rofi colors applied to ~/.Xresources and ~/.config/rofi/colors.rasi"
    else
        echo "Warning: colors-rofi.rasi not found in ~/.cache/wal/"
    fi

    if file_exists ~/.cache/wal/colors-rofi-wal.rasi; then
        echo "Setting up rofi colors..."
        cp ~/.cache/wal/colors-rofi-wal.rasi ~/.config/rofi/wal/colors-rofi.rasi
        echo "Rofi colors  ~/.config/rofi/wal/colors-rofi.rasi"
    else
        echo "Warning: colors-rofi.rasi not found in ~/.cache/wal/"
    fi

    if file_exists ~/.cache/wal/dunstrc; then
        echo "Setting up dunst colors..."
        cp ~/.cache/wal/dunstrc ~/.config/dunst/dunstrc
        echo "dunst colors ~/.config/dunst/dunstrc"
    else
        echo "Warning: dunstrc not found in ~/.cache/wal/"
    fi

    if file_exists ~/.cache/wal/polybar; then
        echo "Setting up polybar colors..."
        cp ~/.cache/wal/polybar ~/.config/polybar/blocks/colors.ini
        sleep 1
        "$HOME"/.config/polybar/blocks/scripts/popup-manager.sh bluetooth --hide
        "$HOME"/.config/polybar/blocks/scripts/popup-manager.sh sysinfo --hide
        "$HOME"/.config/polybar/blocks/scripts/popup-manager.sh general --hide
        "$HOME"/.config/polybar/blocks/scripts/popup-manager.sh tray --hide
        echo "polybar colors ~/.config/polybar/blocks/colors.ini"
    else
        echo "Warning: polybar not found in ~/.cache/wal/"
    fi
}

# Function to kill and refresh programs
refresh_programs() {
    # Kill already running processes that need refresh
    _ps=(rofi dunst)
    for _prs in "${_ps[@]}"; do
        if pidof "${_prs}" >/dev/null; then
            pkill "${_prs}"
        fi
    done
    
    echo "Programs refreshed"
}

# Main color setup
echo "Setting up workspace colors..."

# Setup Xresources as before
cat ~/Xresources-empty > ~/.Xresources 
cat ~/.cache/wal/colors.Xresources >> ~/.Xresources

# Add DWM colors if available
if file_exists ~/.cache/wal/my-dwm.h; then
    cat ~/.cache/wal/my-dwm.h >> ~/.Xresources 
fi

# Add Polybar colors if available
if file_exists ~/.cache/wal/colors-polybar; then
    cat ~/.cache/wal/colors-polybar >> ~/.Xresources
fi

# Setup rofi colors
setup_rofi_colors

# Merge Xresources
xrdb -merge ~/.Xresources

# Refresh programs
refresh_programs

# Trigger DWM refresh (if using the keybind)
xdotool key super+F5

echo "Workspace colors setup complete!"
# #!/bin/bash
# # Save as ~/bin/change-colors.sh
# # wal -i ~/Pictures/b.png --backend wal
# cat ~/Xresources-empty > ~/.Xresources 
# cat ~/.cache/wal/colors.Xresources >> ~/.Xresources
# cat ~/.cache/wal/my-dwm.h >> ~/.Xresources 
# cat ~/.cache/wal/colors-polybar >> ~/.Xresources
# xrdb -merge ~/.Xresources
# xdotool key super+F5
