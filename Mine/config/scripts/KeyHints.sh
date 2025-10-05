#!/usr/bin/env bash
# WORKS {fix the keybinds when i finish}
# Uses yad; adapted for X11 and dwm

# Check if rofi is running and kill it
if pgrep -x "rofi" > /dev/null; then
    pkill rofi
fi

# Detect screen resolution under X11
# Method 1: using xrandr
res=$(xrandr | grep '*' | awk '{print $1}' | head -n1)
# Fallback method using xdpyinfo if xrandr fails
if [ -z "$res" ]; then
    res=$(xdpyinfo | awk '/dimensions:/ {print $2; exit}')
fi

# Split into width and height
x_mon=${res%x*}
y_mon=${res#*x}

# Just in case, if either is empty, set defaults
: "${x_mon:=1920}"
: "${y_mon:=1080}"

# You can decide a scale factor or scaling if you like, but skipping Hyprland scale
# Calculate width & height based on percentages
percentage_width=70
percentage_height=70

dynamic_width=$(( x_mon * percentage_width / 100 ))
dynamic_height=$(( y_mon * percentage_height / 100 ))

# Optional caps
max_width=1200
max_height=1000
if [ "$dynamic_width" -gt "$max_width" ]; then
    dynamic_width=$max_width
fi
if [ "$dynamic_height" -gt "$max_height" ]; then
    dynamic_height=$max_height
fi

# Launch yad window floating / on top
# Use --undecorated or --sticky or --always-on-top depending on YAD version
# --geometry can also help if you want precise position
yad --width="$dynamic_width" --height="$dynamic_height" \
    --center \
    --undecorated \
    --on-top \
    --title="Keybindings" \
    --no-buttons \
    --list \
    --column=Key: \
    --column=Command: \
    --column=Description: \
    ""                             ""                                "" \
    ""                          "GENERAL SECTION"                ""\
    ""                             ""                                "" \
    "ESC"                          "Close This App"                  "" \
    " L"                          "Lock"                            "Lock Screen" \
    " Q"                          "Close"                           "Normal Close Window" \
    " Alt B"                      "Toggle Bar"                      "Show/Hide Polybar" \
    " Space"                      "Toggle Floating"                 "Make Window Floating" \
    " Alt P"                      "Pin Floating"                    "Make Floating Window Follow" \
    " Shift F"                    "Toggle FullScreen"               "Make Window FullScreen" \
    " 3 Fingers Swipe Left/Right" "Move"                     "Move To Tag Left/Right" \
    " "                          "Focus Up/Down/Left/Right Window" "Change Focus" \
    " Shift "                    "Move Window Up/Down/Left/Right"  "Move Window" \
    " Control Space"              "Swap Focus"                      "Swap Focus Between 2 Latest Windows" \
    " Shift Control Space"        "Swap Window"                     "Swap Between 2 Latest Windows" \
    " Z"                          "Swap Window"                     "Swap Current Window With Master" \
    " Alt "                      "Move View"                       "Move To Left/Right Tag" \
    " Control "                  "Move Window"                     "Move Window To Left/Right Tag" \
    " 1-9"                        "Move View"                       "View Tag 1-9" \
    " Shift 1-9"                  "Move Window"                     "Move Window To Tag 1-9" \
    " Ctrl 1-9"                   "Combined/Uncombined View"        "View Multiple Tags At Once/Or Remove From View" \
    " Ctrl Shift 1-9"             "Clone/Unclone"                   "Clone Window To Multiple Tags" \
    " 0"                          "View All"                        "View All Open Windows" \
    " Shift 0"                    "Move Window"                     "Move Window To 0 Tag To Make It Show In All Tags" \
    " Shift S"                    "Select Window"                   "In View ALL Select Window To Move View To" \
    "Alt Tab"                      "Alt-Tab"                         "Like Windows Alt-Tab" \
    " Shift Control Left/Right"   "Change Monitor"                  "Changed Focused Monitor" \
    " Shift Control Down/Up"      "Change Monitor"                  "Move Window To Another Monitor And Focus Monitor" \
    " Alt Comma/Period"           "Change Monitor"                  "Changed Focused Monitor" \
    " Shift Comma/Period"         "Change Monitor"                  "Move Window To Another Monitor And Focus Monitor" \
    ""                             ""                                "" \
    ""                          "APP SECTION"                     ""\
    ""                             ""                                "" \
    " Enter"                      "Terminal"                        "Kitty" \
    " SHIFT enter"                "DropDown Terminal"               "Kitty-ScratchPad" \
    " F"                          "Open File Manager"               "Thunar" \
    " B"                          "Open Browser"                    "Vivaldi" \
    " Alt P"                      "Open PureRef"                    "Image Refrences" \
    " Shift L"                    "Open Llm"                        "Msty Ollama" \
    " Control Z"                  "Zoom"                            "Boomer Zoom" \
    " Control Enter"              "Open Cool Term"                  "Cool-Retro-Term" \
    " N"                          "Open Notion"                     "Notion Todo" \
    " Shift Control C"            "Open Notion"                     "Notion Calendar" \
    " R"                          "Open Koodo"                      "Epub Reader" \
    " O"                          "Open Obsidian"                   "Notes" \
    " Shift O"                    "Open Office"                     "LibreOffice" \
    " P"                          "Open Okular"                     "Pdf Reader" \
    " G"                          "Open Git"                        "GitKraken" \
    " Shift Z"                    "Open Zeditor"                    "Zed Editor" \
    " Shift B"                    "Open Zen Browser"                "Zen" \
    " K"                          "Open Kate"                       "Kate Editor" \
    " Alt E"                      "Reload Emacs"                    "Reload Emacs Client" \
    " E"                          "Open Emacs"                      "Emacs Client" \
    " T"                          "Open Emacs"                      "Emacs Todo" \
    " Alt N"                      "Open Emacs"                      "Emacs Notes" \
    " Control N"                  "Open Emacs"                      "Emacs Notes Directory" \
    " Control T"                  "Open Emacs"                      "Emacs Captures" \
    " A"                          "Open Emacs"                      "Emacs Agenda" \
    " Alt Shift E"                "Open Emacs"                      "Emacs Emal" \
    ""                             ""                                "" \
    ""                          "SCRIPT SECTION"                  ""\
    ""                             ""                                "" \
    " Shift W"                    "Change Colors"                   "Pic Wallpaper For Pywal Colors Only" \
    " Shift I"                    "Idle Toggle"                     "Prevends Computer From Susbending" \
    "Fn F1"                        "Mute"                            "Mute Audio" \
    "Fn F2"                        "Volume Decreace"                 "Decreace Audio By 5" \
    "Fn F3"                        "Volume Increase"                 "Increase Audio By 5" \
    "Fn F11"                       "Decreace Brightness"             "Decreace Backlight By 5" \
    "Fn F12"                       "Increase Brightness"             "Increase Backlight By 5" \
    "Alt Fn F11"                   "Decrease Keyboard Light"         "3 Levels Of Keyboard Backlight" \
    "Alt Fn F12"                   "Increase Keyboard Light"         "3 Levels Of Keyboard Backlight" \
    " Shift N"                    "Next"                            "Skip A Song" \
    " Shift P"                    "Previus"                         "Go Back A Song" \
    " Control P"                  "Music Toggle"                    "Pause/Unpause Music" \
    " Alt Space"                  "Stop Music"                      "Stops Music Source" \
    " Alt A"                      "Airplane"                        "Airplane Mode" \
    " Shift A"                    "Audio Switch"                    "Generic Audio Output Switch" \
    " Control A"                  "Audio Switch"                    "Audio Output Switch From Preset Outputs" \
    " Control C"                  "ColorPicker"                     "ColorPicker That Also Saves In Clipboard" \
    " Shift Q"                    "Force Close"                     "Force Close Window" \
    " Control S"                  "ScreenShot"                      "Monitor ScreenShot" \
    " Shift S"                    "ScreenShot"                      "Select Area By Draging Or Click Window To ScreenShot" \
    " Control R"                  "Record"                          "Record Window No Audio" \
    " Alt R"                      "Record"                          "Select Area By Draging Or Click Window To Record No Audio" \
    " Alt Control R"              "Record"                          "Record Window With Audio" \
    " Alt Shift R"                "Record"                          "Select Area By Draging Or Click Window To Record With Audio" \
    " Shift R"                    "Reload"                          "Reload Dwm After Changes" \
    " SHIFT /"                    "Keybinds Yad"                    "Clear Keybinds" \
    " Control X"                  "Force Quit"                      "Exit Dwm Forcefully" \
    ""                             ""                                "" \
    ""                          "ROFI SECTIOM"                    ""\
    ""                             ""                                "" \
    " D"                          "Rofi Launcher"                   "Aplication launcher" \
    " C"                          "Rofi Calculator"                 "Calculator" \
    " V"                          "Rofi Clipboard"                  "Clipboard" \
    " X"                          "Rofi Sysmenu"                    "Sysmenu + Process Killer" \
    " M"                          "Rofi Music Player"               "Locale/Online Music Player" \
    " W"                          "Rofi Wallpaper"                  "Wallpaper Picker + Pywal Colors" \
    " Comma"                      "Rpfi Emoji"                      "Emoji Picker" \
    " Control D"                  "Rofi Document"                   "Open Pdfs With Rofi" \
    " Alt S"                      "Rofi Websearch"                  "Websearch From Anywhere" \
    " Control M"                  "Rofi Man"                        "Open Man Pages" \
    " Control E"                  "Rofi Equalizer"                  "Output/Input Equalizer" \
    " Shift Control A"            "Rofi Arch Wiki"                  "Locale Arch Wiki" \
    " Alt M"                      "Rofi Relacing Sounds"            "Relaxing Sounds Like Rain Fire Etc" \
    " Alt D"                      "Rofi Dictionary"                 "Online Dictionary" \
    " Alt C"                      "Rofi SpellCheck"                 "Online SpellChecker" \
    " /"                          "Rofi Keybinds"                   "Searchable Keybinds" \
    " Shift E"                    "Rofi Edit"                       "Quick Access to configs" \
    ""                             ""                                "" \
    ""                          "DMENU SECTION"                   ""\
    ""                             ""                                "" \
    " Shift D"                    "Dmenu Launcher"                  "Aplication Launcher" \
    " Shift C"                    "Dmenu Calculator"                "Calculator" \
    " Shift V"                    "Dmenu Clipboard"                 "Clipboard" \
    " Shift X"                    "Dmenu Sysmenu"                   "Sysmenu + Process Killer" \
    " Shift M"                    "Dmenu Music Player"              "Locale/Online Music Player" \
    " Alt W"                      "Dmenu Wallpaper"                 "Wallpaper Picker + Pywal Colors" \
    " Shift Control D"            "Dmenu Document"                  "Open Pdfs With Dmenu" \
    " Alt Shift S"                "Dmenu Websearch"                 "Websearch From Anywhere" \
    " Shift Control M"            "Dmenu Man"                       "Open Man Pages" \
    " Shift Control E"            "Dmenu Equalizer"                 "Output/Input Equalizer" \
    " Shift Alt A"                "Dmenu Arch Wiki"                 "Locale Arch Wiki" \
    " Shift Alt M"                "Dmenu Relaxing Sounds"           "Relaxing Sounds Like Rain Fire Etc" \
    " Shift Alt D"                "Dmenu Dictionary"                "Online Dictionary" \
    " Shift Alt C"                "Dmenu SpellCheck"                "Online SpellChecker" \
    " Control V"                  "Dmenu Video"                     "Play Videos With Mpv" \
    ""                             ""                                "" \
