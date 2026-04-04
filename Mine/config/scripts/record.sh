#!/usr/bin/env bash
# WORKS
#
set -euo pipefail
export DISPLAY="${DISPLAY:-:0}"

# Default output directory
OUTDIR="${HOME}/Videos"
mkdir -p "${OUTDIR}"

# Output filename with timestamp
current="$(date +%Y%m%d_%H%M%S).mp4"
filepath="${OUTDIR}/${current}"

# Check if a recording is already in progress
pidfile="${HOME}/.screen_recording_pid"
if [[ -f "${pidfile}" ]]; then
    pid=$(cat "${pidfile}")
    if kill -0 "${pid}" 2>/dev/null; then
        # Stop the recording
        kill -s SIGINT "${pid}"
        rm -f "${pidfile}"
        notify-send "Screen Recording" "Recording stopped."
        exit 0
    else
        rm -f "${pidfile}"
    fi
fi

# Parse arguments
SELECT_MODE=0
AUDIO_MODE=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        -s)
            SELECT_MODE=1
            shift
            ;;
        -w)
            SELECT_MODE=2
            shift
            ;;
        -a)
            AUDIO_MODE=1
            shift
            ;;
        -as)
            SELECT_MODE=1
            AUDIO_MODE=1
            shift
            ;;
        *)
            OUTDIR="$1"
            shift
            ;;
    esac
done

mkdir -p "${OUTDIR}"

# Get the default audio source for recording
get_audio_source() {
    # Try to get the default audio source
    # First try pulseaudio
    if command -v pactl >/dev/null 2>&1; then
        # Get default sink monitor (what's playing on speakers)
        default_sink=$(pactl info | grep "Default Sink" | cut -d' ' -f3)
        if [[ -n "$default_sink" ]]; then
            echo "${default_sink}.monitor"
            return
        fi
    fi
    
    # Fallback to ALSA
    if command -v arecord >/dev/null 2>&1; then
        echo "default"
        return
    fi
    
    # If nothing works, return empty (no audio)
    echo ""
}

# Get the active monitor information
get_active_monitor() {
    # Get mouse position to determine active monitor
    eval $(xdotool getmouselocation --shell)
    
    # Get all monitor information
    xrandr --listactivemonitors | grep -E "^ [0-9]" | while read -r line; do
        # Parse monitor info: number: +*width/mmWidth x height/mmHeight+x_offset+y_offset  name
        monitor_info=$(echo "$line" | awk '{print $3}')
        geometry=$(echo "$monitor_info" | sed 's/.*+//' | tr '+' ' ')
        read -r width height x_offset y_offset <<< $(echo "$monitor_info" | sed -E 's|([0-9]+)/[0-9]+x([0-9]+)/[0-9]+\+([0-9]+)\+([0-9]+).*|\1 \2 \3 \4|')
        
        # Check if mouse is within this monitor
        if [[ $X -ge $x_offset && $X -lt $((x_offset + width)) && $Y -ge $y_offset && $Y -lt $((y_offset + height)) ]]; then
            echo "$width $height $x_offset $y_offset"
            return
        fi
    done
    
    # Fallback to full screen if no active monitor detected
    screen_res=$(xdpyinfo | awk '/dimensions/ {print $2}')
    echo "${screen_res/x/ } 0 0"
}

# Build FFmpeg command based on audio requirements
build_ffmpeg_cmd() {
    local video_input="$1"
    local base_cmd="ffmpeg -f x11grab -video_size ${W}x${H} -framerate 25 -i ${video_input}"
    
    if [[ $AUDIO_MODE -eq 1 ]]; then
        local audio_source=$(get_audio_source)
        if [[ -n "$audio_source" ]]; then
            # Add audio input
            if command -v pactl >/dev/null 2>&1; then
                # Use PulseAudio
                base_cmd="${base_cmd} -f pulse -i ${audio_source}"
            else
                # Use ALSA
                base_cmd="${base_cmd} -f alsa -i ${audio_source}"
            fi
            # Add audio codec
            base_cmd="${base_cmd} -c:v libx264 -preset ultrafast -crf 0 -c:a aac -b:a 128k -threads 0"
        else
            notify-send "Screen Recording" "Warning: No audio source found, recording video only."
            base_cmd="${base_cmd} -c:v libx264 -preset ultrafast -crf 0 -threads 0"
        fi
    else
        # No audio
        base_cmd="${base_cmd} -c:v libx264 -preset ultrafast -crf 0 -threads 0"
    fi
    
    echo "${base_cmd} \"${filepath}\""
}

# Determine recording mode
if [[ $SELECT_MODE -eq 1 ]]; then
    # Area selection mode
    slop_output=$(slop --nokeyboard --noopengl --nodecorations -f "%x %y %w %h")
    read -r X Y W H <<< $slop_output
    
    ffmpeg_cmd=$(build_ffmpeg_cmd "${DISPLAY}+${X},${Y}")
    eval "${ffmpeg_cmd} &"
    
elif [[ $SELECT_MODE -eq 2 ]]; then
    # Window selection mode
    window_id=$(slop --nokeyboard --noopengl --nodecorations -f "%i")
    eval $(xwininfo -id $window_id | awk -F ': ' '/Width/ {print "W="$2} /Height/ {print "H="$2} /Absolute upper-left X/ {print "X="$2} /Absolute upper-left Y/ {print "Y="$2}')
    
    ffmpeg_cmd=$(build_ffmpeg_cmd "${DISPLAY}+${X},${Y}")
    eval "${ffmpeg_cmd} &"
    
else
    # Full screen mode - record active monitor
    read -r W H X Y <<< $(get_active_monitor)
    
    if [[ $X -eq 0 && $Y -eq 0 ]]; then
        # Single monitor or fallback - use simple display format
        ffmpeg_cmd=$(build_ffmpeg_cmd "${DISPLAY}")
        eval "${ffmpeg_cmd} &"
    else
        # Multi-monitor setup - specify offset for active monitor
        ffmpeg_cmd=$(build_ffmpeg_cmd "${DISPLAY}+${X},${Y}")
        eval "${ffmpeg_cmd} &"
    fi
fi

# Save the process ID to the pidfile
echo $! > "${pidfile}"

# Show appropriate notification
if [[ $AUDIO_MODE -eq 1 ]]; then
    notify-send "Screen Recording" "Recording with audio started: ${current}"
else
    notify-send "Screen Recording" "Recording started: ${current}"
fi
