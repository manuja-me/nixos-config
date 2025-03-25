#!/usr/bin/env bash

# Enhanced brightness control script with notifications
# Uses brightnessctl for brightness control

ACTION=$1
STEP=5

get_brightness() {
    brightnessctl -m | cut -d',' -f4 | tr -d '%'
}

brightness_notification() {
    brightness=$(get_brightness)
    
    if [ "$brightness" -lt 30 ]; then
        icon="display-brightness-low"
    elif [ "$brightness" -lt 70 ]; then
        icon="display-brightness-medium"
    else
        icon="display-brightness-high"
    fi
    
    # Create a progress bar
    progress=""
    bar_length=20
    filled_length=$((brightness * bar_length / 100))
    
    for ((i=0; i<filled_length; i++)); do
        progress+="■"
    done
    
    for ((i=filled_length; i<bar_length; i++)); do
        progress+="□"
    done
    
    notify-send -c brightness -u low -i "$icon" "Brightness: $brightness%" "$progress" -t 1000 -h int:value:"$brightness"
}

case $ACTION in
    "--inc")
        brightnessctl set ${STEP}%+
        brightness_notification
        ;;
    "--dec")
        brightnessctl set ${STEP}%-
        brightness_notification
        ;;
    *)
        echo "Usage: $0 {--inc|--dec}"
        exit 1
        ;;
esac
