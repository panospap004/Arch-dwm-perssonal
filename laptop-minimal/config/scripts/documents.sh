#!/bin/bash
# WORKS
# Script name: documents
# Description: Search for PDFs to open.
# Dependencies: dmenu OR fzf OR rofi, zathura, mupdf (or another PDF viewer)
    # -h  displays this help page
    # -d  runs the script using 'dmenu'
    # -f  runs the script using 'fzf'
    # -r  runs the script using 'rofi'

set -euo pipefail

# Configuration
DMENU="dmenu -i -l 20 -g 2 -p"
RMENU="rofi -i -dmenu -config ~/.config/rofi/config-compact.rasi -p"
FMENU="fzf --bind=enter:replace-query+print-query --border=rounded --margin=5% --color=dark --height 100% --reverse --header=$(basename "$0") --info=hidden --header-first --prompt"
# PDF_VIEWER="zathura"  # Change to your preferred PDF viewer
PDF_VIEWER="mupdf"  # Change to your preferred PDF viewer

# Helper functions
err() {
    printf 'Error: %s\n' "$1"
    exit 1
}

get_menu_program() {
    while getopts "dfrh" arg 2>/dev/null; do
        case "${arg}" in
        d) echo "${DMENU}"; return 0 ;;
        f) echo "${FMENU}"; return 0 ;;
        r) echo "${RMENU}"; return 0 ;;
        h) help; return 1 ;;
        *) echo "invalid option: Type $(basename "$0") -h for help" >/dev/stderr; return 1 ;;
        esac
    done
    echo "${DMENU}"
}

help() {
    printf '%s\n' "Usage: $(basename "$0") [options]
Description: Search for PDFs to open.
Dependencies: dmenu OR fzf OR rofi, zathura (or another PDF viewer)

The following OPTIONS are accepted:
    -h  displays this help page
    -d  runs the script using 'dmenu'
    -f  runs the script using 'fzf'
    -r  runs the script using 'rofi'

Running $(basename "$0") without any argument defaults to using 'dmenu'

PDF viewer: $PDF_VIEWER
Search depth: 4 levels from home directory"
}

main() {
    # Check if PDF viewer is available
    if ! command -v ${PDF_VIEWER} >/dev/null 2>&1; then
        err "PDF viewer '${PDF_VIEWER}' is required but not installed"
    fi

    # Find PDF files in home directory (max depth 4 to avoid too many results)
    files="$(find "$HOME" -maxdepth 4 -iname "*.pdf" 2>/dev/null)"
    
    if [ -z "$files" ]; then
        err "No PDF files found in home directory (searched 4 levels deep)"
    fi

    # Format the file list for display
    choice=$(printf '%s\n' "${files[@]}" \
        | cut -d '/' -f4- \
        | sed -e 's/Documents/Docs/g' \
            -e 's/Downloads/Down/g' \
            -e 's/Pictures/Pics/g' \
            -e 's/Images/Imgs/g' \
            -e 's/.pdf//g' \
        | sort -g \
        | ${MENU} "PDF File: ") || exit 1
        
    if [ -z "$choice" ]; then
        echo "No file selected."
        exit 0
    fi

    # Convert back to full path
    file=$(printf '%s' "$choice" \
        | sed -e 's/Docs/Documents/g' \
            -e 's/Down/Downloads/g' \
            -e 's/Pics/Pictures/g' \
            -e 's/Imgs/Images/g')

    full_path="$HOME/${file}.pdf"
    
    # Check if file exists
    if [ ! -f "$full_path" ]; then
        err "File not found: $full_path"
    fi

    # Open the PDF
    "${PDF_VIEWER}" "$full_path" &
    echo "Opened: $full_path"
}

MENU="$(get_menu_program "$@")"
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main
