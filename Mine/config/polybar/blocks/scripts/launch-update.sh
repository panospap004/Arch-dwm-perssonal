#!/usr/bin/env bash
kitty --title "System Update" -e bash -lc "
set -e
echo '=== System Update Started ==='
echo 'This will update your system packages...'
echo

if yay -Syu; then
    echo
    echo '=== Update Completed Successfully! ==='
    echo 'Your system has been updated.'
else
    echo
    echo '=== Update Failed or Cancelled ==='
    echo 'The update process was not completed.'
fi

echo
echo 'Press Enter to close this window...'
read -r
"
