#!/usr/bin/env bash
# WORKS
#
set -euo pipefail
export DISPLAY="${DISPLAY:-:0}"

# Get script directory for sound script
sDIR="$(dirname "$(readlink -f "$0")")"

# Function to play screenshot sound
play_screenshot_sound() {
    if [[ -x "${sDIR}/Sounds.sh" ]]; then
        "${sDIR}/Sounds.sh" --screenshot &
    fi
}

# Default output directory
OUTDIR="${HOME}/Screenshots"
SELECT_MODE=0

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -s)
            SELECT_MODE=1
            shift
            ;;
        *)
            OUTDIR="$1"
            shift
            ;;
    esac
done

mkdir -p "${OUTDIR}"
current="$(date +%Y%m%d_%H%M%S).png"
filepath="${OUTDIR}/${current}"

# Determine screenshot utility
tool_path="$(command -v import 2>/dev/null || command -v scrot 2>/dev/null)" || {
    notify-send "Screenshot Tool Missing" "Neither 'import' nor 'scrot' is installed!"
    echo "Error: No screenshot tool found."
    exit 1
}

TOOL="$(basename "${tool_path}")"

# Select flags based on tool and SELECT_MODE
flags=()
if [[ "${TOOL}" == "scrot" ]]; then
    [[ $SELECT_MODE -eq 1 ]] && flags=(--select)
elif [[ "${TOOL}" == "import" ]]; then
    [[ $SELECT_MODE -eq 0 ]] && flags=(-window root)
fi

# xset -b   # disable bell

"$TOOL" "${flags[@]}" "${filepath}" || {
    notify-send "Screenshot Failed" "Could not save screenshot to ${filepath}."
    exit 1
}

# xset b on # restore bell

# Play screenshot sound
play_screenshot_sound

# Copy screenshot to clipboard
xclip -selection clipboard -t image/png -i "${filepath}"

notify-send "Screenshot Taken" "Saved as ${current} in ${OUTDIR} and copied to clipboard"

# #!/usr/bin/env bash
# set -euo pipefail
# export DISPLAY="${DISPLAY:-:0}"
#
# # Get script directory for sound script
# sDIR="$(dirname "$(readlink -f "$0")")"
#
# # Function to play screenshot sound
# play_screenshot_sound() {
#     if [[ -x "${sDIR}/Sounds.sh" ]]; then
#         "${sDIR}/Sounds.sh" --screenshot &
#     fi
# }
#
# # Default output directory
# OUTDIR="${HOME}/Screenshots"
# SELECT_MODE=0
#
# # Parse arguments
# while [[ $# -gt 0 ]]; do
#     case "$1" in
#         -s)
#             SELECT_MODE=1
#             shift
#             ;;
#         *)
#             OUTDIR="$1"
#             shift
#             ;;
#     esac
# done
#
# mkdir -p "${OUTDIR}"
# current="$(date +%Y%m%d_%H%M%S).png"
# filepath="${OUTDIR}/${current}"
#
# # Determine screenshot utility
# tool_path="$(command -v import 2>/dev/null || command -v scrot 2>/dev/null)" || {
#     notify-send "Screenshot Tool Missing" "Neither 'import' nor 'scrot' is installed!"
#     echo "Error: No screenshot tool found."
#     exit 1
# }
#
# TOOL="$(basename "${tool_path}")"
#
# # Select flags based on tool and SELECT_MODE
# flags=()
# if [[ "${TOOL}" == "scrot" ]]; then
#     [[ $SELECT_MODE -eq 1 ]] && flags=(--select)
# elif [[ "${TOOL}" == "import" ]]; then
#     [[ $SELECT_MODE -eq 0 ]] && flags=(-window root)
# fi
#
# xset -b   # disable bell
#
# "$TOOL" "${flags[@]}" "${filepath}" || {
#     notify-send "Screenshot Failed" "Could not save screenshot to ${filepath}."
#     exit 1
# }
#
# xset b on # restore bell
#
# # Play screenshot sound
# play_screenshot_sound
#
# notify-send "Screenshot Taken" "Saved as ${current} in ${OUTDIR}"
