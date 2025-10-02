#!/usr/bin/env bash
# WORKS
# Script name: wiki
# Description: Search an offline copy of the Arch Wiki.
# Dependencies: dmenu OR fzf OR rofi, arch-wiki-docs, a browser

set -euo pipefail

# Configuration
DMENU="dmenu -i -l 20 -g 2 -p"
RMENU="rofi -i -dmenu -config ~/.config/rofi/config-compact.rasi -p"
FMENU="fzf --bind=enter:replace-query+print-query --border=rounded --margin=5% --color=dark --height 100% --reverse --header=$(basename "$0") --info=hidden --header-first --prompt"
DMBROWSER="vivaldi"  # Change to your preferred browser

# Wiki directory - change if your arch-wiki-docs is installed elsewhere
wikidir="/usr/share/doc/arch-wiki/html/"

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
Description: Search an offline copy of the Arch Wiki.
Dependencies: dmenu OR fzf OR rofi, arch-wiki-docs, a browser

The following OPTIONS are accepted:
    -h  displays this help page
    -d  runs the script using 'dmenu'
    -f  runs the script using 'fzf'
    -r  runs the script using 'rofi'

Running $(basename "$0") without any argument defaults to using 'dmenu'

Note: This script requires arch-wiki-docs to be installed.
The wiki files should be located in: $wikidir"
}

languages() {
    # Check if wiki directory exists
    if [ ! -d "$wikidir" ]; then
        err "Arch Wiki directory not found at $wikidir. Please install arch-wiki-docs or adjust the wikidir variable."
    fi

    # Check if browser is available
    if ! command -v ${DMBROWSER%% *} >/dev/null 2>&1; then
        err "Browser '${DMBROWSER%% *}' is required but not installed"
    fi

    langs="$(find ${wikidir} -maxdepth 1 -type d -not -path "${wikidir}")"
    if [ -z "$langs" ]; then
        err "No language directories found in $wikidir"
    fi

    choice=$(printf '%s\n' "${langs[@]}" \
        | sed 's/.*\///' \
        | sort -g \
        | ${MENU} 'Language: ') || exit 1

    if [ "$choice" ]; then
        lang=$(printf '%s' "${choice}/")
        echo "$lang"
        wikipages
    else
        echo "Program terminated." && exit 0
    fi
}

wikipages() {
    wikidocs="$(find ${wikidir}"${lang}" -iname "*.html")"
    if [ -z "$wikidocs" ]; then
        err "No wiki documents found in ${wikidir}${lang}"
    fi

    choice=$(printf '%s\n' "${wikidocs[@]}" \
        | cut -d '/' -f8- \
        | sed -e 's/_/ /g' -e 's/.html//g' \
        | sort -g \
        | ${MENU} 'Arch Wiki Docs: ') || exit 1

    if [ "$choice" ]; then
        article=$(printf '%s\n' "${wikidir}${lang}${choice}.html" | sed 's/ /_/g')
        ${DMBROWSER} "$article"
    else
        echo "Program terminated." && exit 0
    fi
}

main() {
    languages
}

MENU="$(get_menu_program "$@")"
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main
