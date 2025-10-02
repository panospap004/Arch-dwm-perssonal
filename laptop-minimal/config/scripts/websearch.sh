#!/usr/bin/env bash
# works
# Script name: websearch
# Description: Search various search engines (inspired by surfraw).
# Dependencies: dmenu OR fzf OR rofi, curl, a web browser

set -euo pipefail

# Configuration
DMENU="dmenu -i -l 20 -g 2 -p"
RMENU="rofi -i -dmenu -config ~/.config/rofi/config-compact.rasi -p"
FMENU="fzf --bind=enter:replace-query+print-query --border=rounded --margin=5% --color=dark --height 100% --reverse --header=$(basename "$0") --info=hidden --header-first --prompt"
DMBROWSER="vivaldi"  # Change to your preferred browser

# Search engines configuration
declare -Ag websearch
websearch[bing]="https://www.bing.com/search?q="
websearch[brave]="https://search.brave.com/search?q="
websearch[duckduckgo]="https://duckduckgo.com/?q="
websearch[google]="https://www.google.com/search?q="
websearch[qwant]="https://www.qwant.com/?q="
websearch[swisscows]="https://swisscows.com/web?query="
websearch[yandex]="https://yandex.com/search/?text="
websearch[bbcnews]="https://www.bbc.co.uk/search?q="
websearch[cnn]="https://www.cnn.com/search?q="
websearch[googlenews]="https://news.google.com/search?q="
websearch[wikipedia]="https://en.wikipedia.org/w/index.php?search="
websearch[wiktionary]="https://en.wiktionary.org/w/index.php?search="
websearch[reddit]="https://www.reddit.com/search/?q="
websearch[odysee]="https://odysee.com/$/search?q="
websearch[youtube]="https://www.youtube.com/results?search_query="
websearch[amazon]="https://www.amazon.com/s?k="
websearch[craigslist]="https://www.craigslist.org/search/sss?query="
websearch[ebay]="https://www.ebay.com/sch/i.html?&_nkw="
websearch[gumtree]="https://www.gumtree.com/search?search_category=all&q="
websearch[archaur]="https://aur.archlinux.org/packages/?O=0&K="
websearch[archpkg]="https://archlinux.org/packages/?sort=&q="
websearch[archwiki]="https://wiki.archlinux.org/index.php?search="
websearch[debianpkg]="https://packages.debian.org/search?suite=default&section=all&arch=any&searchon=names&keywords="
websearch[github]="https://github.com/search?q="
websearch[gitlab]="https://gitlab.com/search?search="
websearch[sourceforge]="https://sourceforge.net/directory/?q="
websearch[stackoverflow]="https://stackoverflow.com/search?q="

# Default fallback search engine
DEFAULT_ENGINE="google"

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
Description: Search various search engines (inspired by surfraw).
Dependencies: dmenu OR fzf OR rofi, curl, a web browser

OPTIONS:
    -h  Show this help page
    -d  Use dmenu
    -f  Use fzf
    -r  Use rofi

Default: dmenu"
}

main() {
    if [ -z "${!websearch[*]}" ]; then
        err "No search engines configured"
    fi
    
    # Step 1: ask user for engine or direct input
    engine_or_query=$(printf '%s\n' "${!websearch[@]}" | sort | ${MENU} 'Choose engine or type URL/query:') || exit 1

    # Case 1: Direct URL / domain
    if [[ "$engine_or_query" =~ ^https?://.* ]] || [[ "$engine_or_query" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        ${DMBROWSER} "$engine_or_query"
        exit 0
    fi

    # Case 2: Valid engine
    if [[ -n "${websearch[$engine_or_query]+x}" ]]; then
        url="${websearch[$engine_or_query]}"
        query=$(printf '' | ${MENU} "Enter search query:")
    else
        # Case 3: Fallback to default engine
        url="${websearch[$DEFAULT_ENGINE]}"
        query="$engine_or_query"
    fi

    [ -z "$query" ] && exit 0

    # Encode query safely
    query="$(echo -n "${query}" | jq -s -R -r @uri 2>/dev/null || python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.stdin.read().strip()))" <<< "${query}")"
    
    ${DMBROWSER} "${url}${query}"
}

MENU="$(get_menu_program "$@")"
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main
