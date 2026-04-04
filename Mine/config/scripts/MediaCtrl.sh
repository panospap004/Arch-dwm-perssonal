#!/bin/bash
# WORKS
# Media control script that works with both MPD and other players
# needs playerctl
music_icon="$HOME/.config/scripts/icons/icons/music.png"

# Auto-detect which player to use
detect_player() {
    # Check if MPD is running and has music loaded
    if pgrep -x mpd > /dev/null && mpc status 2>/dev/null | grep -q "\["; then
        echo "mpd"
    # Check if playerctl can find any players
    elif playerctl status 2>/dev/null >/dev/null; then
        echo "playerctl"
    else
        echo "none"
    fi
}

# Play the next track
play_next() {
    local player=$(detect_player)
    case "$player" in
        "mpd")
            mpc next >/dev/null
            show_mpd_notification
            ;;
        "playerctl")
            playerctl next
            show_playerctl_notification
            ;;
        "none")
            notify-send -e -u low -i $music_icon "Media Control:" "No active player found"
            ;;
    esac
}

# Play the previous track
play_previous() {
    local player=$(detect_player)
    case "$player" in
        "mpd")
            mpc prev >/dev/null
            show_mpd_notification
            ;;
        "playerctl")
            playerctl previous
            show_playerctl_notification
            ;;
        "none")
            notify-send -e -u low -i $music_icon "Media Control:" "No active player found"
            ;;
    esac
}

# Toggle play/pause
toggle_play_pause() {
    local player=$(detect_player)
    case "$player" in
        "mpd")
            mpc toggle >/dev/null
            show_mpd_notification
            ;;
        "playerctl")
            playerctl play-pause
            show_playerctl_notification
            ;;
        "none")
            notify-send -e -u low -i $music_icon "Media Control:" "No active player found"
            ;;
    esac
}

# Stop playback
stop_playback() {
    local player=$(detect_player)
    case "$player" in
        "mpd")
            mpc stop >/dev/null
            notify-send -e -u low -i $music_icon "Playback (MPD):" "Stopped"
            ;;
        "playerctl")
            playerctl stop
            notify-send -e -u low -i $music_icon "Playback:" "Stopped"
            ;;
        "none")
            notify-send -e -u low -i $music_icon "Media Control:" "No active player found"
            ;;
    esac
}

# Display notification with MPD song information
show_mpd_notification() {
    local status_line=$(mpc status | head -n 2 | tail -n 1)
    
    if echo "$status_line" | grep -q "\[playing\]"; then
        local song_info=$(mpc current)
        notify-send -e -u low -i $music_icon "Now Playing (MPD):" "$song_info"
    elif echo "$status_line" | grep -q "\[paused\]"; then
        notify-send -e -u low -i $music_icon "Playback (MPD):" "Paused"
    fi
}

# Display notification with playerctl song information
show_playerctl_notification() {
    local status=$(playerctl status 2>/dev/null)
    if [[ "$status" == "Playing" ]]; then
        local song_title=$(playerctl metadata title 2>/dev/null)
        local song_artist=$(playerctl metadata artist 2>/dev/null)
        if [[ -n "$song_title" && -n "$song_artist" ]]; then
            notify-send -e -u low -i $music_icon "Now Playing:" "$song_title by $song_artist"
        elif [[ -n "$song_title" ]]; then
            notify-send -e -u low -i $music_icon "Now Playing:" "$song_title"
        else
            notify-send -e -u low -i $music_icon "Now Playing:" "Unknown track"
        fi
    elif [[ "$status" == "Paused" ]]; then
        notify-send -e -u low -i $music_icon "Playback:" "Paused"
    fi
}

# Get media control action from command line argument
case "$1" in
    "--nxt")
        play_next
        ;;
    "--prv")
        play_previous
        ;;
    "--pause")
        toggle_play_pause
        ;;
    "--stop")
        stop_playback
        ;;
    "--status")
        # Debug function to show which player is detected
        player=$(detect_player)
        echo "Detected player: $player"
        if [[ "$player" == "mpd" ]]; then
            mpc status
        elif [[ "$player" == "playerctl" ]]; then
            playerctl status
            playerctl metadata 2>/dev/null
        fi
        ;;
    *)
        echo "Usage: $0 [--nxt|--prv|--pause|--stop|--status]"
        exit 1
        ;;
esac
