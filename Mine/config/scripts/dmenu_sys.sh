#!/usr/bin/env bash
# WORKS

case "$(printf "󰯈 kill\n lock\n suspend\n reboot\n logout\n shutdown" | dmenu -noi -c -l 6 -g 2)" in
	"󰯈 kill") ps -u $USER -o pid,comm,%cpu,%mem | dmenu -i -c -l 10 -g 2 -p Kill: | awk '{print $1}' | xargs -r kill ;;
  " lock") slock -d ;;
  " suspend") slock systemctl suspend -i ;;
  " reboot") pkill -TERM -u $USER ;;
  " logout") systemctl reboot -i ;;
  " shutdown") shutdown now ;;
	*) exit 1 ;;
esac
