#!/usr/bin/env bash
# WORKS

FOLDER="$HOME/Music"

# List of allowed audio/video extensions (lowercase, no dot)
allowed_exts="mp3 wav flac ogg m4a mp4 mkv avi webm"

while true; do
  items=".."

  # Add folder entries first
  for dir in "$FOLDER"/*/; do
    [ -d "$dir" ] && items="$items\n📁 $(basename "$dir")"
  done

  # Add allowed media files
  for file in "$FOLDER"/*; do
    if [ -f "$file" ]; then
      ext="${file##*.}"
      ext_lc="${ext,,}"   # lowercase extension
      # Check if in allowed list
      for a in $allowed_exts; do
        if [ "$ext_lc" = "$a" ]; then
          # Choose icon based on video or audio
          case "$ext_lc" in
            mp4|mkv|avi|webm) icon="🎬" ;;
            *) icon="🎵" ;;
          esac
          items="$items\n$icon $(basename "$file")"
          break
        fi
      done
    fi
  done

  # Show menu
  NAME=$(echo -e "$items" | dmenu -i -c -l 15 -g 2 -p "$(basename "$FOLDER")") || exit 0
  [ -z "$NAME" ] && exit 0

  if [ "$NAME" = ".." ]; then
    # Go up unless we’re at the top folder
    FOLDER=$(dirname "$FOLDER")
    continue
  fi

  CLEAN_NAME="${NAME#📁 }"
  CLEAN_NAME="${CLEAN_NAME#🎵 }"
  CLEAN_NAME="${CLEAN_NAME#🎬 }"

  if [ -d "$FOLDER/$CLEAN_NAME" ]; then
    FOLDER="$FOLDER/$CLEAN_NAME"
  else
    mpv "$FOLDER/$CLEAN_NAME" >/dev/null 2>&1 &
    exit 0
  fi
done
