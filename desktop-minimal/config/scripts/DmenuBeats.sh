#!/bin/bash
# radio works only with mpv
# Works with both MPD and MPV - Auto detects which one to use {needs mpd mpv mpc youtube-dl yt-dlp mpv-mpris mpd-mpris}
# For dmenu Beats to play online Music or Locally save media files

# Directory local music folder
mDIR="$HOME/Music/"

# Directory for icons
iDIR="$HOME/.config/scripts/icons/icons"

# dmenu configuration
DMENU_CMD="dmenu -i -c -l 20 -g 2"

# Auto-detect music player (MPD preferred if running, fallback to MPV)
detect_player() {
  if systemctl --user is-active --quiet mpd || pgrep -x mpd > /dev/null; then
    echo "mpd"
  elif command -v mpv > /dev/null; then
    echo "mpv"
  else
    notify-send -u critical "Error" "Neither MPD nor MPV found!"
    exit 1
  fi
}

PLAYER=$(detect_player)

# Online Stations. Edit as required
declare -A online_music=(
["Radio - Oldies Radio 50s-60s 📻🎶"]="https://zeno.fm/radio/oldies-radio-50s-60s/"
  ["Radio - Oldies Radio 70s 📻🎶"]="https://zeno.fm/radio/oldies-radio-70s/"
  ["Radio - Unlimited 80s 📻🎶"]="https://zeno.fm/radio/unlimited80s/"
  ["Radio - 80s Hits 📻🎶"]="https://zeno.fm/radio/80shits/"
  ["Radio - 90s Hits 📻🎶"]="https://zeno.fm/radio/90s_HITS/"
  ["Radio - 2000s Pop 📻🎶"]="https://zeno.fm/radio/2000s-pop/"
  ["Radio - The 2000s 📻🎶"]="https://zeno.fm/radio/the-2000s/"
  ["Radio - Hits 2010s 📻🎶"]="https://zeno.fm/radio/helia-hits-2010/"
  ["Radio - Classical Radio 🎼🎶"]="https://zeno.fm/radio/classical-radio/"
  ["Radio - Classical Relaxation 🎼🎶"]="https://zeno.fm/radio/radio-christmas-non-stop-classical/"
  ["Radio - Classic Rock 🎸🎶"]="https://zeno.fm/radio/classic-rockdnb2sav8qs8uv/"
  ["Radio - Gangsta49 🎤🎶"]="https://zeno.fm/radio/gangsta49/"
  ["Radio - HipHop49 🎤🎶"]="https://zeno.fm/radio/hiphop49/"
  ["Radio - Madhouse Country Radio 🤠🎶"]="https://zeno.fm/radio/madhouse-country-radio/"
  ["Radio - PopMusic 📻🎶"]="https://zeno.fm/radio/popmusic74vyurvmug0uv/"
  ["Radio - PopStars 🌟🎶"]="https://zeno.fm/radio/popstars/"
  ["Radio - RadioMetal 🤘🎶"]="https://zeno.fm/radio/radio-metal/"
  ["Radio - RocknRoll Radio 🎸🎶"]="https://zeno.fm/radio/rocknroll-radio994c7517qs8uv/"
  ["Radio - Lofi Girl 🎧🎶"]="https://play.streamafrica.net/lofiradio"
  ["Radio - Chillhop 🎧🎶"]="http://stream.zeno.fm/fyn8eh3h5f8uv"
  ["Radio - Ibiza Global 🎧🎶"]="https://filtermusic.net/ibiza-global"
  ["Radio - Metal Music 🎧🎶"]="https://tunein.com/radio/mETaLmuSicRaDio-s119867/"
  ["FM - Easy Rock 96.3 📻🎶"]="https://radio-stations-philippines.com/easy-rock"
  ["FM - Easy Rock - Baguio 91.9 📻🎶"]="https://radio-stations-philippines.com/easy-rock-baguio"
  ["FM - Love Radio 90.7 📻🎶"]="https://radio-stations-philippines.com/love"
  ["FM - WRock - CEBU 96.3 📻🎶"]="https://onlineradio.ph/126-96-3-wrock.html"
  ["FM - Fresh Philippines 📻🎶"]="https://onlineradio.ph/553-fresh-fm.html"
  ["YT - Wish 107.5 YT Pinoy HipHop 📻🎶"]="https://youtube.com/playlist?list=PLkrzfEDjeYJnmgMYwCKid4XIFqUKBVWEs&si=vahW_noh4UDJ5d37"
  ["YT - Top Youtube Music 2023 📹🎶"]="https://youtube.com/playlist?list=PLDIoUOhQQPlXr63I_vwF9GD8sAKh77dWU&si=y7qNeEVFNgA-XxKy"
  ["YT - Wish 107.5 YT Wishclusives 📹🎶"]="https://youtube.com/playlist?list=PLkrzfEDjeYJn5B22H9HOWP3Kxxs-DkPSM&si=d_Ld2OKhGvpH48WO"
  ["YT - Relaxing Music 📹🎶"]="https://youtube.com/playlist?list=PLMIbmfP_9vb8BCxRoraJpoo4q1yMFg4CE"
  ["YT - Youtube Remix 📹🎶"]="https://youtube.com/playlist?list=PLeqTkIUlrZXlSNn3tcXAa-zbo95j0iN-0"
  ["YT - Korean Drama OST 📹🎶"]="https://youtube.com/playlist?list=PLUge_o9AIFp4HuA-A3e3ZqENh63LuRRlQ"
  ["YT - AfroBeatz 2024 📹🎶"]="https://www.youtube.com/watch?v=7uB-Eh9XVZQ"
  ["YT - Relaxing Piano Jazz Music 🎹🎶"]="https://youtu.be/85UEqRat6E4?si=jXQL1Yp2VP_G6NSn"
  ["YT - Relaxing Piano Music 🎹🎶"]="https://youtu.be/6H7hXzjFoVU?si=nZTPREC9lnK1JJUG"
  ["YT - Korean Drama OST 📹🎶"]="https://youtube.com/playlist?list=PLUge_o9AIFp4HuA-A3e3ZqENh63LuRRlQ"
  ["YT - Youtube Top 100 Songs Global 📹🎶"]="https://youtube.com/playlist?list=PL4fGSI1pDJn6puJdseH2Rt9sMvt9E2M4i&si=5jsyfqcoUXBCSLeu"
  ["YT - Lofi Hip Hop Radio Beats 📹🎶"]="https://www.youtube.com/live/jfKfPfyJRdk?si=PnJIA9ErQIAw6-qd"
  ["YT - Lofi Japanese Hip Hop 📹🎶"]="https://www.youtube.com/watch?v=qCa64XOO5Ng"
  ["YT - Lofi Hip Hop Jiraiya 📹🎶"]="https://www.youtube.com/watch?v=z59jAKESVp4"
  ["YT - Lofi Hip Hop Kakashi 📹🎶"]="https://www.youtube.com/watch?v=MEt2iinZ56c"
  ["YT - Lofi Minecraft Rain 📹🎶"]="https://www.youtube.com/watch?v=Mi12nUC2QKo&t=19178s"
  ["YT - Lofi Minecraft And Chill 📹🎶"]="https://www.youtube.com/watch?v=TsTtqGAxvWk"
  ["YT - Lofi Minecraft 📹🎶"]="https://www.youtube.com/watch?v=CIfGUiICf8U"
  ["YT - Minecraft Bgm Rain 📹🎶"]="https://www.youtube.com/watch?v=qLuc8kZty1A"
  ["YT - Epic Violin 📹🎶"]="https://www.youtube.com/watch?v=iceS6BvhuQ8"
  ["YT - Lofi Coding Session 📹🎶"]="https://www.youtube.com/watch?v=qZjWUkohSQg"
  ["YT - Lofi Code-fi 📹🎶"]="https://www.youtube.com/watch?v=f02mOEt11OQ"
  ["YT - Lofi My Playlist 📹🎶"]="https://www.youtube.com/watch?v=qCa64XOO5Ng&list=PLWN6KAmpUSVMJpPj_bZAEdVu3-wq1GPvz"
  ["YT - Lofi Morning Coffe 📹🎶"]="https://www.youtube.com/watch?v=1fueZCTYkpA"
  ["YT - Lofi Girl Best Of 2021 📹🎶"]="https://www.youtube.com/watch?v=n61ULEU7CO0"
  ["YT - Lofi Girl Best Of 2022 📹🎶"]="https://www.youtube.com/watch?v=i43tkaTXtwI"
  ["YT - Lofi Girl Best Of 2023 📹🎶"]="https://www.youtube.com/watch?v=mmKguZohAck"
  ["YT - Lofi Girl Best Of 2024 📹🎶"]="https://www.youtube.com/watch?v=lA9FONoiuFA"
  ["YT - Lofi 12am Session 📹🎶"]="https://www.youtube.com/watch?v=l98w9OSKVNA"
  ["YT - Lofi 1am Session 📹🎶"]="https://www.youtube.com/watch?v=lTRiuFIWV54"
  ["YT - Lofi 2am Session 📹🎶"]="https://www.youtube.com/watch?v=wAPCSnAhhC8"
  ["YT - Lofi 3am Session 📹🎶"]="https://www.youtube.com/watch?v=BTYAsjAVa3I"
  ["YT - Lofi 4am Session 📹🎶"]="https://www.youtube.com/watch?v=TURbeWK2wwg"
  ["YT - Lofi 3am Coding Session 📹🎶"]="https://www.youtube.com/watch?v=8nXqcugV2Y4&t=2s"
  ["YT - Lofi old School Runescape 📹🎶"]="https://www.youtube.com/watch?v=5Vzc-KIawBI"
  ["YT - Lofi 90s Rain 📹🎶"]="https://www.youtube.com/watch?v=q1pBwQl6zZ0"
  ["YT - Lofi 90s Hip Hop 📹🎶"]="https://www.youtube.com/watch?v=AMcVJmb5mvk"
  ["YT - Jazz Zutomaya & Yaosobi 📹🎶"]="https://www.youtube.com/watch?v=hEyGRA0K-Do&t=5054s"
  ["YT - Pokemon Jazz 📹🎶"]="https://www.youtube.com/watch?v=hvuojhm02Yk"
  ["YT - Lofi Bgm Pokemon 📹🎶"]="https://www.youtube.com/watch?v=SzsJJDDjO5I"
  ["YT - Lofi Pokemon Relaxing 📹🎶"]="https://www.youtube.com/watch?v=SVt86cLo4tA&t=16275s"
  ["YT - Lofi Pokemon Littleroot 📹🎶"]="https://www.youtube.com/watch?v=6CjpgFOOtuI"
  ["YT - Bgm Pokemon 📹🎶"]="https://www.youtube.com/watch?v=YMEblRM4pGc"
  ["YT - Pokemon Vol 1 📹🎶"]="https://www.youtube.com/watch?v=-BKfhq_TtcE"
  ["YT - Pokemon Vol 2 📹🎶"]="https://www.youtube.com/watch?v=U4cFS_Yircg"
  ["YT - Pokemon Vol 3 📹🎶"]="https://www.youtube.com/watch?v=msoaACG940Y&t=6s"
  ["YT - Your Lie In April All Sonatas 📹🎶"]="https://www.youtube.com/watch?v=i0Q7T_9vNNE"
  ["YT - Stardew Valley Bgm 📹🎶"]="https://www.youtube.com/watch?v=JJCFQtTPq_8"
  ["YT - Legends Of Zelda Bgm Rain 📹🎶"]="https://www.youtube.com/watch?v=ozCtwI8nQ-s"
  ["YT - Mario Bgm Piano 📹🎶"]="https://www.youtube.com/watch?v=l359nRYMolg"
  ["YT - Mario Jazz 📹🎶"]="https://www.youtube.com/watch?v=VAl7q9dHGwY&t=8s"
  ["YT - Mario Jazz Rain 📹🎶"]="https://www.youtube.com/watch?v=NpRO8TYHpic"
  ["YT - Animal Crossing Rain 📹🎶"]="https://www.youtube.com/watch?v=1wOAhRAqb40"
  ["YT - Studio Ghibli Bgm Hillside 📹🎶"]="https://www.youtube.com/watch?v=TjPwQlOjzb8"
  ["YT - Studio Ghibli Bgm Sea 📹🎶"]="https://www.youtube.com/watch?v=5Jn198qc9X4"
  ["YT - Studio Ghibli Bgm Ship 📹🎶"]="https://www.youtube.com/watch?v=Yz4HQO6Z6vw"
  ["YT - Studio Ghibli Bgm Snow 📹🎶"]="https://www.youtube.com/watch?v=f9KldL-gaeY"
  ["YT - Studio Ghibli Bgm Flowers 📹🎶"]="https://www.youtube.com/watch?v=SPj3KYtGlQk"
  ["YT - Studio Ghibli Bgm Forest 📹🎶"]="https://www.youtube.com/watch?v=fAGrM6P3IKQ"
  ["YT - Studio Ghibli Bgm Woods 📹🎶"]="https://www.youtube.com/watch?v=GEKLmXNUFaE"
  ["YT - Studio Ghibli Bgm River 📹🎶"]="https://www.youtube.com/watch?v=tlMU0_fetQI"
  ["YT - Studio Ghibli Bgm Totoro 📹🎶"]="https://www.youtube.com/watch?v=oQUA3tQS0To&t=5s"
  ["YT - Studio Ghibli Bgm Spirited 📹🎶"]="https://www.youtube.com/watch?v=zdlu7gQm3b0"
  ["YT - Studio Ghibli Bgm Marnie 📹🎶"]="https://www.youtube.com/watch?v=OO0CxVfqceQ"
  ["YT - Studio Ghibli Bgm Ponyo 📹🎶"]="https://www.youtube.com/watch?v=IT1dFWE_YN8"
  ["YT - Relaxing Medieval City 📹🎶"]="https://www.youtube.com/watch?v=RqHR6J4tR3Q"
  ["YT - Relaxing Medieval Drunken 📹🎶"]="https://www.youtube.com/watch?v=ZMjHOaJAWwU&t=25709s"
  ["YT - Relaxing Medieval Rain 📹🎶"]="https://www.youtube.com/watch?v=AZbtV7F2EQo"
  ["YT - Medival Celtic 📹🎶"]="https://www.youtube.com/watch?v=ipFaubyDUT4"
  ["YT - Japanese Shemisen Rock 📹🎶"]="https://www.youtube.com/watch?v=tWzZhZU3sOI&t=2s"
  ["YT - Japanese Shemisen Rock Lady 📹🎶"]="https://www.youtube.com/watch?v=KBgRUHG6pHU"
  ["YT - Japanese Shemisen Battle Rock 📹🎶"]="https://www.youtube.com/watch?v=NL-wl5wJm4s&t=6s"
  ["YT - Japanese Drum and Bass 📹🎶"]="https://www.youtube.com/watch?v=lBb8jI6bS2U"
  ["YT - Japanese Shemisen Rock Crow 📹🎶"]="https://www.youtube.com/watch?v=kN1Y_4BVe3g"
  ["YT - Japanese Shemisen Okami 📹🎶"]="https://www.youtube.com/watch?v=bd5B4BAS9LQ"
  ["YT - Japanese Shemisen Boss 📹🎶"]="https://www.youtube.com/watch?v=wGO2SxIK1OM"
  ["YT - Japanese Shemisen Fight 📹🎶"]="https://www.youtube.com/watch?v=0B328vXZqVA"
  ["YT - Japanese Shemisen Elecric 📹🎶"]="https://www.youtube.com/watch?v=YnIjwexkoEY"
  ["YT - Japanese Shemisen Theme 📹🎶"]="https://www.youtube.com/watch?v=ygy7M5iw_Rg"
)

# Function for displaying notifications
notification() {
  notify-send -u normal -i "$iDIR/music.png" "Now Playing ($1):" " $2"
}

# Function to stop current music
stop_music() {
  case "$PLAYER" in
    "mpd")
      mpc stop
      mpc clear
      ;;
    "mpv")
      pkill mpv
      ;;
  esac
}

# Function to stop all music (both MPD and MPV)
stop_all_music() {
  # Stop MPD if running
  if systemctl --user is-active --quiet mpd || pgrep -x mpd > /dev/null; then
    mpc stop 2>/dev/null
    mpc clear 2>/dev/null
  fi
  # Stop MPV if running
  if pgrep -x mpv > /dev/null; then
    pkill mpv
  fi
}

# Function to check if any music is playing
is_music_playing() {
  # Check MPD
  if systemctl --user is-active --quiet mpd || pgrep -x mpd > /dev/null; then
    if mpc | grep -q "\[playing\]" 2>/dev/null; then
      echo "mpd"
      return 0
    fi
  fi
  # Check MPV
  if pgrep -x mpv > /dev/null; then
    echo "mpv"
    return 0
  fi
  return 1
}

# Function to play with MPD
play_with_mpd() {
  local action="$1"
  shift
  local files=("$@")

  mpc clear
  case "$action" in
    "single")
      # Convert absolute path to relative path from MPD music directory
      local relative_path="${files[0]#$mDIR}"
      mpc add "$relative_path"
      mpc play
      ;;
    "playlist")
      for file in "${files[@]}"; do
        local relative_path="${file#$mDIR}"
        mpc add "$relative_path"
      done
      mpc shuffle
      mpc repeat on
      mpc play
      ;;
    "stream")
      mpc add "${files[0]}"
      mpc play
      ;;
    "folder")
      # Add entire folder
      local relative_path="${files[0]#$mDIR}"
      mpc add "$relative_path"
      mpc shuffle
      mpc repeat on
      mpc play
      ;;
  esac
}

# Function to play with MPV
play_with_mpv() {
  local action="$1"
  shift
  local files=("$@")

  case "$action" in
    "single")
      mpv --vid=no "${files[0]}"
      ;;
    "playlist")
      mpv --shuffle --loop-playlist --vid=no "${files[@]}"
      ;;
    "stream")
      mpv --shuffle --vid=no "${files[0]}"
      ;;
    "folder")
      mpv --shuffle --loop-playlist --vid=no "${files[0]}"
      ;;
  esac
}

# Universal play function
play_music() {
  local action="$1"
  shift
  local files=("$@")

  case "$PLAYER" in
    "mpd")
      play_with_mpd "$action" "${files[@]}"
      ;;
    "mpv")
      play_with_mpv "$action" "${files[@]}"
      ;;
  esac
}

# Main function for playing local music with recursive search
play_local_music() {
  local current_dir="$mDIR"
  while true; do
    # Build list: subdirectories first then music files (recursive play)
    items=()
    while IFS= read -r item; do
      items+=("$item")
    done < <(find "$current_dir" -mindepth 1 -maxdepth 1 -type d | sort)
    while IFS= read -r item; do
      items+=("$item")
    done < <(find "$current_dir" -mindepth 1 -maxdepth 1 -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.wav" -o -iname "*.ogg" -o -iname "*.mp4" \) | sort)

    # Add parent directory option if not at root
    if [ "$current_dir" != "$mDIR" ]; then
      items=(".. (Parent Directory)" "${items[@]}")
    fi

    # Prepare display list (only basenames)
    display_items=()
    for item in "${items[@]}"; do
      if [ "$item" == ".. (Parent Directory)" ]; then
        display_items+=("$item")
      else
        display_items+=("$(basename "$item")")
      fi
    done

    choice=$(printf "%s\n" "${display_items[@]}" | $DMENU_CMD -p "Local Music: $current_dir")
    [ -z "$choice" ] && break

    if [ "$choice" == ".. (Parent Directory)" ]; then
      current_dir=$(dirname "$current_dir")
      continue
    fi

    selected_path=""
    for item in "${items[@]}"; do
      if [ "$item" == ".. (Parent Directory)" ]; then
        continue
      fi
      if [ "$(basename "$item")" == "$choice" ]; then
        selected_path="$item"
        break
      fi
    done

    [ -z "$selected_path" ] && continue

    if [ -d "$selected_path" ]; then
      current_dir="$selected_path"
    elif [ -f "$selected_path" ]; then
      # Gather all music files recursively from the current folder
      notification "$PLAYER" "$choice"
      mapfile -t playlist < <(find "$current_dir" -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.wav" -o -iname "*.ogg" -o -iname "*.mp4" \))
      [ "${#playlist[@]}" -eq 0 ] && { notify-send "No music files found in $current_dir"; continue; }
      play_music "playlist" "${playlist[@]}"
      break
    fi
  done
}

# New function: Play local music in selected folder ONLY (no children)
play_local_music_no_children() {
  local current_dir="$mDIR"
  while true; do
    # Build list: subdirectories first then music files (non-recursive)
    items=()
    while IFS= read -r item; do
      items+=("$item")
    done < <(find "$current_dir" -mindepth 1 -maxdepth 1 -type d | sort)
    while IFS= read -r item; do
      items+=("$item")
    done < <(find "$current_dir" -mindepth 1 -maxdepth 1 -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.wav" -o -iname "*.ogg" -o -iname "*.mp4" \) | sort)

    # Add parent directory option if not at the root
    if [ "$current_dir" != "$mDIR" ]; then
      items=(".. (Parent Directory)" "${items[@]}")
    fi

    # Prepare display list
    display_items=()
    for item in "${items[@]}"; do
      if [ "$item" == ".. (Parent Directory)" ]; then
        display_items+=("$item")
      else
        display_items+=("$(basename "$item")")
      fi
    done

    choice=$(printf "%s\n" "${display_items[@]}" | $DMENU_CMD -p "Local Music (No Children): $current_dir")
    [ -z "$choice" ] && break

    if [ "$choice" == ".. (Parent Directory)" ]; then
      current_dir=$(dirname "$current_dir")
      continue
    fi

    selected_path=""
    for item in "${items[@]}"; do
      [ "$item" == ".. (Parent Directory)" ] && continue
      if [ "$(basename "$item")" == "$choice" ]; then
        selected_path="$item"
        break
      fi
    done

    [ -z "$selected_path" ] && continue

    if [ -d "$selected_path" ]; then
      current_dir="$selected_path"
    elif [ -f "$selected_path" ]; then
      # Gather only the music files in the current folder (non-recursive)
      notification "$PLAYER" "$choice"
      mapfile -t playlist < <(find "$current_dir" -maxdepth 1 -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.wav" -o -iname "*.ogg" -o -iname "*.mp4" \))
      [ "${#playlist[@]}" -eq 0 ] && { notify-send "No music files found in $current_dir"; continue; }
      play_music "playlist" "${playlist[@]}"
      break
    fi
  done
}

# Populate local_music array with files from music directory and subdirectories
populate_local_music() {
  local_music=()
  filenames=()
  while IFS= read -r file; do
    local_music+=("$file")
    filenames+=("$(basename "$file")")
  done < <(find "$mDIR" -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.wav" -o -iname "*.ogg" -o -iname "*.mp4" \))
}

# Main function for playing all local music
play_all_local_music() {
  populate_local_music
  choice=$(printf "%s\n" "${filenames[@]}" | $DMENU_CMD -p "Local Music")
  [ -z "$choice" ] && exit 1
  for (( i=0; i<"${#filenames[@]}"; ++i )); do
    if [ "${filenames[$i]}" = "$choice" ]; then
      notification "$PLAYER" "$choice"
      # For MPD, we need to handle playlist starting differently
      if [ "$PLAYER" == "mpd" ]; then
        mpc clear
        for file in "${local_music[@]}"; do
          local relative_path="${file#$mDIR}"
          mpc add "$relative_path"
        done
        mpc play $((i+1))  # MPD uses 1-based indexing
        mpc repeat on
      else
        mpv --playlist-start="$i" --loop-playlist --vid=no "${local_music[@]}"
      fi
      break
    fi
  done
}

# Main function for shuffling local music (entire folder)
shuffle_local_music() {
  notification "$PLAYER" "Shuffle Play local music"
  play_music "folder" "$mDIR"
}

# Main function for playing online music (always uses MPV)
play_online_music() {
  choice=$(printf "%s\n" "${!online_music[@]}" | $DMENU_CMD -p "Online Music")
  [ -z "$choice" ] && exit 1
  link="${online_music[$choice]}"
  notification "mpv" "$choice"
  play_with_mpv "stream" "$link"
}

# Check if music is playing and stop it, otherwise run the main function
playing_player=$(is_music_playing)
if [ $? -eq 0 ]; then
  stop_all_music
  notify-send -u low -i "$iDIR/music.png" "Music stopped ($playing_player)"
  exit 0
fi

# Kill dmenu if running (though dmenu usually doesn't persist)
pkill -f dmenu 2>/dev/null

user_choice=$(printf "Play from Online Stations\nShuffle and play (Selected and children folder)\nShuffle Play (Selected Folder Only)\nPlay all songs from Music\nShuffle Play from Music Folder" | $DMENU_CMD -p "Select music source ($PLAYER)")

case "$user_choice" in
  "Play from Online Stations")
    play_online_music
    ;;
  "Shuffle and play (Selected and children folder)")
    play_local_music
    ;;
  "Shuffle Play (Selected Folder Only)")
    play_local_music_no_children
    ;;
  "Play all songs from Music")
    play_all_local_music
    ;;
  "Shuffle Play from Music Folder")
    shuffle_local_music
    ;;
  *)
    echo "Invalid choice"
    ;;
esac
