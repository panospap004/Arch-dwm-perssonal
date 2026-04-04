#!/usr/bin/env bash
# Universal media player script for polybar using playerctl + MPD support
# Shows current playing media from any MPRIS-compatible player or MPD

# Player icons (you can customize these)
declare -A player_icons=(
    ["spotify"]=""
    ["firefox"]=""
    ["chromium"]=""
    ["chrome"]=""
    ["mpv"]="󰐹"
    ["vlc"]="󰕼"
    ["mpd"]="󰐹"
    ["mopidy"]=""
    ["kdeconnect"]=""
    ["default"]=""
)

# Status icons
play_icon=""
pause_icon="󰐎"
stop_icon=""
prev_icon="󰒮"
next_icon="󰒭"

# Colors (can be overridden by polybar)
COLOR_PLAYING="${COLOR_PLAYING:-#61C766}"
COLOR_PAUSED="${COLOR_PAUSED:-#EBD369}"
COLOR_STOPPED="${COLOR_STOPPED:-#9E9E9E}"
COLOR_BG_ALT="${COLOR_BG_ALT:-#423949}"
COLOR_FG="${COLOR_FG:-#FFFFFF}"

# Function to get player icon
get_player_icon() {
    local player="$1"
    echo "${player_icons[$player]:-${player_icons[default]}}"
}

# Function to get status icon
get_status_icon() {
    local status="$1"
    case "$status" in
        "Playing") echo "$play_icon" ;;
        "Paused") echo "$pause_icon" ;;
        "Stopped") echo "$stop_icon" ;;
        *) echo "$stop_icon" ;;
    esac
}

# Function to get status color (for player icon background)
get_status_color() {
    local status="$1"
    case "$status" in
        "Playing") echo "$COLOR_PLAYING" ;;
        "Paused") echo "$COLOR_PAUSED" ;;
        "Stopped") echo "$COLOR_STOPPED" ;;
        *) echo "$COLOR_STOPPED" ;;
    esac
}

# Function to check MPD status
get_mpd_info() {
    if command -v mpc &> /dev/null; then
        local mpd_status=$(mpc status 2>/dev/null)
        local current_song=$(mpc current 2>/dev/null)
        
        # Only return MPD info if there's actually a song and it's playing/paused
        if [ -n "$mpd_status" ] && [ -n "$current_song" ]; then
            if echo "$mpd_status" | grep -q "\[playing\]"; then
                local artist=$(mpc current -f "%artist%" 2>/dev/null || echo "Unknown")
                local title=$(mpc current -f "%title%" 2>/dev/null || echo "No Title")
                echo "mpd|Playing|$artist|$title"
                return 0
            elif echo "$mpd_status" | grep -q "\[paused\]"; then
                local artist=$(mpc current -f "%artist%" 2>/dev/null || echo "Unknown")
                local title=$(mpc current -f "%title%" 2>/dev/null || echo "No Title")
                echo "mpd|Paused|$artist|$title"
                return 0
            fi
        fi
    fi
    return 1
}

# Function to truncate text
truncate_text() {
    local text="$1"
    local max_len="${2:-25}"
    if [ ${#text} -gt $max_len ]; then
        echo "${text:0:$((max_len-3))}..."
    else
        echo "$text"
    fi
}

# Main function
main() {
    # First try MPD
    mpd_info=$(get_mpd_info)
    if [ $? -eq 0 ]; then
        IFS='|' read -r player status artist title <<< "$mpd_info"
        clean_player="mpd"
    else
        # Check if playerctl is available
        if ! command -v playerctl &> /dev/null; then
            echo "%{F$COLOR_FG}%{B$COLOR_BG_ALT} No playerctl %{B-}%{F-}"
            exit 1
        fi
        
        # Get active players
        players=$(playerctl --list-all 2>/dev/null)
        
        if [ -z "$players" ]; then
            echo "%{F$COLOR_FG}%{B$COLOR_BG_ALT} No players %{B-}%{F-}"
            exit 0
        fi
        
        # Get the first active player with media
        active_player=""
        for player in $players; do
            status=$(playerctl --player="$player" status 2>/dev/null)
            if [[ "$status" == "Playing" || "$status" == "Paused" ]]; then
                active_player="$player"
                break
            fi
        done
        
        # If no playing/paused player, get the first one
        if [ -z "$active_player" ]; then
            active_player=$(echo "$players" | head -n1)
        fi
        
        # Get player info
        status=$(playerctl --player="$active_player" status 2>/dev/null || echo "Stopped")
        artist=$(playerctl --player="$active_player" metadata artist 2>/dev/null || echo "Unknown")
        title=$(playerctl --player="$active_player" metadata title 2>/dev/null || echo "No Title")
        
        # Clean player name (remove .instance suffix)
        clean_player=$(echo "$active_player" | sed 's/\.[0-9]*$//')
    fi
    
    # Get icons and colors
    player_icon=$(get_player_icon "$clean_player")
    status_icon=$(get_status_icon "$status")
    status_color=$(get_status_color "$status")
    
    # Format the output
    if [ "$artist" != "Unknown" ] && [ "$title" != "No Title" ]; then
        media_text="$artist - $title"
    else
        media_text="$title"
    fi
    
    # Truncate if too long
    media_text=$(truncate_text "$media_text" 30)
    
    # Output with polybar formatting - player icon with status color, prev/status/next with same color as text
    echo "%{F$COLOR_FG}%{B$status_color} $player_icon %{B-}%{F-}%{F$COLOR_FG}%{B$COLOR_BG_ALT} $media_text %{B-}%{F-}%{F$COLOR_FG}%{B$COLOR_BG_ALT} $prev_icon $status_icon $next_icon %{B-}%{F-}"
}

# Run main function
main "$@"
