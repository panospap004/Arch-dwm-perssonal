#!/usr/bin/env bash
# WORKS
# rofi + greenclip integration: select an entry and greenclip will put it in the clipboard

# kill existing rofi instance (optional)
if pidof rofi > /dev/null; then
  pkill rofi
fi

# ensure greenclip daemon is running (try systemd user first, fallback to daemon)
if ! pgrep -x greenclip >/dev/null; then
  if command -v systemctl >/dev/null && systemctl --user status greenclip.service >/dev/null 2>&1; then
    systemctl --user start greenclip.service 2>/dev/null || greenclip daemon &
  else
    greenclip daemon &
  fi
fi

while true; do
    rofi -modi "clipboard:greenclip print" -show clipboard \
         -i \
         -a 0 \
         -kb-custom-1 "Control-Delete" \
         -kb-custom-2 "Alt-Delete" \
         -config ~/.config/rofi/config-clipboard.rasi

    rc=$?
    case "$rc" in
        1)
            exit
            ;;
        0)
            exit
            ;;
        10)
            greenclip clear
            ;;
        11)
            greenclip clear
            ;;
        *)
            ;;
    esac
done
