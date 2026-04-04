#!/bin/bash
# Enhanced weather script for polybar with forecast support
# Outputs both icon and temperature with formatting

city="Athens-greece"
cachedir=~/.cache/weather
cachefile_current="weather-current"
cachefile_forecast="weather-forecast"

# Create cache directory if it doesn't exist
[ ! -d "$cachedir" ] && mkdir -p "$cachedir"

# Function to get weather icon
get_weather_icon() {
    local condition=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case "$condition" in
        *clear*|*sunny*)
            echo "";;
        *"partly cloudy"*)
            echo "󰖕";;
        *cloudy*)
            echo "";;
        *overcast*)
            echo "";;
        *fog*|*mist*)
            echo "";;
        *drizzle*|*"light rain"*)
            echo "󰼳";;
        *"moderate rain"*|*"heavy rain"*|*"rain shower"*)
            echo "";;
        *sleet*|*freezing*)
            echo "󰼴";;
        *"light snow"*)
            echo "󰙿";;
        *"heavy snow"*|*blizzard*)
            echo "";;
        *thunder*)
            echo "";;
        *)
            echo "";;
    esac
}

# Function to fetch current weather
fetch_current_weather() {
    local cache_age=$(($(date +%s) - $(stat -c '%Y' "$cachedir/$cachefile_current" 2>/dev/null || echo 0)))
    
    if [ $cache_age -gt 1800 ] || [ ! -s "$cachedir/$cachefile_current" ]; then
        curl -s "https://en.wttr.in/${city}?format=%l|%C|%t|%h|%w|%p" > "$cachedir/$cachefile_current" 2>/dev/null
    fi
}

# Function to fetch forecast
fetch_forecast() {
    local cache_age=$(($(date +%s) - $(stat -c '%Y' "$cachedir/$cachefile_forecast" 2>/dev/null || echo 0)))
    
    if [ $cache_age -gt 3600 ] || [ ! -s "$cachedir/$cachefile_forecast" ]; then
        # Fetch 7-day forecast in a parseable format
        curl -s "https://en.wttr.in/${city}?format=j1" > "$cachedir/$cachefile_forecast" 2>/dev/null
    fi
}

# Function to parse and display forecast with dunst
show_forecast() {
    fetch_forecast
    
    if [ ! -s "$cachedir/$cachefile_forecast" ]; then
        dunstify -u normal "Weather Forecast" "Unable to fetch forecast data"
        return
    fi
    
    # Parse JSON forecast data using jq if available
    if command -v jq &> /dev/null; then
        local forecast_text=""
        
        # Show today + next 2 days (3 days total)
        for i in 0 1 2; do
            local day_data=$(jq -r ".weather[$i]" "$cachedir/$cachefile_forecast" 2>/dev/null)
            if [ "$day_data" != "null" ] && [ -n "$day_data" ]; then
                local date=$(echo "$day_data" | jq -r '.date')
                local max_temp=$(echo "$day_data" | jq -r '.maxtempC')
                local min_temp=$(echo "$day_data" | jq -r '.mintempC')
                local desc=$(echo "$day_data" | jq -r '.hourly[4].weatherDesc[0].value')
                
                # Get day name
                local day_name=$(date -d "$date" "+%A" 2>/dev/null || echo "Day$((i+1))")
                [ $i -eq 0 ] && day_name="Today"
                [ $i -eq 1 ] && day_name="Tomorrow"
                
                # Get weather icon
                local icon=$(get_weather_icon "$desc")
                
                # Format: day_name current weather icon_of_weather highest_temp/lowest_temp
                forecast_text="${forecast_text}${day_name}: ${icon} ${max_temp}°C/${min_temp}°C\n"
            fi
        done
        
        # Send to dunst with proper formatting
        dunstify -u normal -t 10000 -r 9999 "🌤 Weather Forecast - ${city}" "${forecast_text}"
    else
        # Fallback: Get 3-day forecast without jq
        local forecast_data=""
        for i in 0 1 2; do
            local day_forecast=$(curl -s "https://en.wttr.in/${city}?${i}d&format=%C|%t|%M" 2>/dev/null | head -n 1)
            if [ -n "$day_forecast" ]; then
                IFS='|' read -r condition temp moon <<< "$day_forecast"
                local icon=$(get_weather_icon "$condition")
                local day_name="Day $((i+1))"
                [ $i -eq 0 ] && day_name="Today"
                [ $i -eq 1 ] && day_name="Tomorrow"
                forecast_data="${forecast_data}${day_name}: ${icon} ${temp}\n"
            fi
        done
        dunstify -u normal -t 10000 -r 9999 "🌤 Weather Forecast - ${city}" "${forecast_data}"
    fi
}

# Function to handle mouse clicks
handle_click() {
    case "$1" in
        3) # Right click - show 3-day forecast
            show_forecast
            ;;
        # Left click removed - not needed
    esac
}

# Main execution
main() {
    # Handle polybar click events (only right-click now)
    if [ "$1" = "3" ]; then
        handle_click "$1"
        exit 0
    fi
    
    # Fetch current weather
    fetch_current_weather
    
    if [ ! -s "$cachedir/$cachefile_current" ]; then
        echo " N/A"
        exit 1
    fi
    
    # Parse current weather data
    local weather_data=$(cat "$cachedir/$cachefile_current")
    IFS='|' read -r location condition temp humidity wind precipitation <<< "$weather_data"
    
    # Clean up temperature (remove spaces and +/- signs)
    temp=$(echo "$temp" | sed 's/[[:space:]]*//g' | sed 's/+//g')
    
    # Get weather icon
    local icon=$(get_weather_icon "$condition")
    
    # Output with polybar formatting tags
    # Use environment variables if passed from polybar, otherwise use defaults
    local color_green="${COLOR_GREEN:-#000000}"
    local color_bg_alt="${COLOR_BG_ALT:-#44475a}"
    local color_fg="${COLOR_FG:-#ffffff}"
    
    # The icon gets green background, temperature gets background-alt
    echo "%{B${color_green}}%{F${color_fg}} ${icon} %{B-}%{F-}%{B${color_bg_alt}}%{F${color_fg}} ${temp} %{B-}%{F-}"
}

# Run main function
main "$@"
