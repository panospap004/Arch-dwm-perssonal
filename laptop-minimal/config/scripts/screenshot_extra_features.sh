#!/usr/bin/env bash
# WORKS
#
set -euo pipefail
export DISPLAY="${DISPLAY:-:0}"
# Get script directory for sound script
sDIR="$(dirname "$(readlink -f "$0")")"

# # Function to disable bell
# disable_bell() {
#     xset -b 2>/dev/null || true
# }
#
# # Function to restore bell
# restore_bell() {
#     xset b on 2>/dev/null || true
# }

# Function to play screenshot sound
play_screenshot_sound() {
    if [[ -x "${sDIR}/Sounds.sh" ]]; then
        "${sDIR}/Sounds.sh" --screenshot &
    fi
}

# Trap to ensure bell is restored on exit
# trap 'restore_bell' EXIT

# Disable bell at start
# disable_bell

# Dependencies check
for cmd in xclip import notify-send; do 
    command -v "$cmd" &>/dev/null || { echo "Missing: $cmd" >&2; exit 1; }
done

OUTDIR="${2:-$HOME/Screenshots}"
mkdir -p "$OUTDIR"
FILE="$OUTDIR/$(date +%Y%m%d_%H%M%S).png"
TMP=$(mktemp --suffix=.png)
# trap 'rm -f "$TMP"; restore_bell' EXIT
trap 'rm -f "$TMP";' EXIT

show_help(){ 
    cat <<EOF
Usage: $0 [color|full|window] [output_dir]
Environment options:
  WATERMARK=1
  WATERMARK_TEXT='text'
  WATERMARK_POS=position
  WATERMARK_SIZE=px
  WATERMARK_BG='#rrggbbaa'
  
Color picker mode:
  - Uses xcolor (recommended), grabc, or gpick
  - Simply click on any pixel to pick its color
  - Color is automatically copied to clipboard
  - Install with: sudo pacman -S xcolor
EOF
}

post(){ 
    [[ "${WATERMARK:-}" == "1" ]] && { 
        command -v magick &>/dev/null || { echo "Missing: magick" >&2; exit 1; }
        # Watermark subsystem (env overrides supported)
        magick "$FILE" \
            -gravity "${WATERMARK_POS:-southeast}" \
            -pointsize "${WATERMARK_SIZE:-28}" \
            -fill white -undercolor "${WATERMARK_BG:-#00000080}" \
            -annotate +20+20 "${WATERMARK_TEXT:-$(date '+%Y-%m-%d %H:%M')}" \
            "$FILE"
    }
    play_screenshot_sound
    xclip -selection clipboard -t image/png -i "$FILE" && notify-send -i "$FILE" "Screenshot: $(basename "$FILE")"
}

colorpicker(){ 
    # Try different color picker tools in order of preference
    if command -v xcolor &>/dev/null; then
        echo "Using xcolor - click on any pixel to pick color"
        local hex=$(xcolor)
        if [[ -n "$hex" && "$hex" != "" ]]; then
            # xcolor returns color without #, so add it
            [[ "$hex" != "#"* ]] && hex="#$hex"
            echo "$hex" | xclip -selection clipboard -i
            
            # Create color preview for notification
            local COLOR_BOX=$(mktemp --suffix=_color.png)
            # trap "rm -f \"$TMP\" \"$COLOR_BOX\"; restore_bell" EXIT
            trap "rm -f \"$TMP\" \"$COLOR_BOX\";" EXIT
            
            if command -v magick &>/dev/null; then
                magick -size 64x64 xc:"$hex" "$COLOR_BOX"
                notify-send -i "$COLOR_BOX" "Color Picked" "$hex"
            else
                notify-send "Color Picked" "$hex"
            fi
            echo "Color picked: $hex (copied to clipboard)"
        else
            echo "Color picking cancelled"
        fi
        
    elif command -v grabc &>/dev/null; then
        echo "Using grabc - click on any pixel to pick color"
        local hex=$(grabc)
        if [[ -n "$hex" && "$hex" != "" ]]; then
            echo "$hex" | xclip -selection clipboard -i
            
            # Create color preview for notification
            local COLOR_BOX=$(mktemp --suffix=_color.png)
            # trap "rm -f \"$TMP\" \"$COLOR_BOX\"; restore_bell" EXIT
            trap "rm -f \"$TMP\" \"$COLOR_BOX\";" EXIT
            
            if command -v magick &>/dev/null; then
                magick -size 64x64 xc:"$hex" "$COLOR_BOX"
                notify-send -i "$COLOR_BOX" "Color Picked" "$hex"
            else
                notify-send "Color Picked" "$hex"
            fi
            echo "Color picked: $hex (copied to clipboard)"
        else
            echo "Color picking cancelled"
        fi
        
    elif command -v gpick &>/dev/null; then
        echo "Using gpick - use the eyedropper tool to pick a color"
        gpick &
        echo "Gpick opened - use the eyedropper tool and copy the color manually"
        
    else
        echo "No color picker found. Please install one of:"
        echo "  sudo pacman -S xcolor      (recommended - simple and fast)"
        echo "  sudo pacman -S grabc       (simple command line picker)"  
        echo "  sudo pacman -S gpick       (full GUI color picker)"
        exit 1
    fi
}

capture_full(){ 
    import -window root "$FILE" && post
}

capture_window(){ 
    command -v xdotool &>/dev/null || { echo "Missing: xdotool" >&2; exit 1; }
    import -window "$(xdotool getwindowfocus -f)" "$FILE" && post
}

capture_selection(){ 
    import "$FILE" && post
}

main(){ 
    case "${1:-}" in
        -h|--help) show_help ;;
        color*)    colorpicker ;;
        full)      capture_full ;;
        window)    capture_window ;;
        *)         capture_selection ;;
    esac
}

main "$@"
