#!/usr/bin/env bash
# WORKS
# Set audio sinks before using!
# `pactl list sinks` if on pulseaudio. OR
# use 'pactl list short sinks' to find your devices
# if on pulseaudio use pacmd else use pactl

headphones () { \
  # pacmd set-default-sink "SET SINK NAME" &
  pactl set-default-sink "SET SINK NAME" &
  notify-send "Audio switched to headphones!" # -h string:bgcolor:#a3be8c "Audio switched to headphones!"
}

speakers () {
  # pacmd set-default-sink "SET SINK NAME" &
  pactl set-default-sink alsa_output.pci-0000_00_1b.0.analog-stereo &
  notify-send "Audio switched to Speakers!" # -h string:bgcolor:#bf616a "Audio switched to Speakers!"
}

bluetooth () { \
  # pacmd set-default-sink "SET SINK NAME" &
  pactl set-default-sink bluez_output.64_68_76_F0_AE_79.1 &
  notify-send "Audio switched to bluetooth!" # -h string:bgcolor:#88c0d0 "Audio switched to bluetooth!"
}

choosespeakers() { \
  choice=$(printf "Headphones\\nSpeakers\\nBluetooth" | dmenu -c -l 3 -g 2 -noi -p "Choose output: ")
  case "$choice" in
    Headphones) headphones;;
    Speakers) speakers;;
    Bluetooth) bluetooth;;
  esac
}

choosespeakers
