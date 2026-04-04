#!/bin/bash
 
 POPUP_PID=$(pgrep -f "polybar popup_tiny")
 
 if [ -n "$POPUP_PID" ]; then
     if [ -f "/tmp/popup_tiny_visible" ]; then
         polybar-msg -p $POPUP_PID cmd hide
         rm /tmp/popup_tiny_visible
     else
         polybar-msg -p $POPUP_PID cmd show
         touch /tmp/popup_tiny_visible
     fi
 fi
