#!/usr/bin/env bash

# Enhanced volume control script with notifications
# Uses pamixer for volume control

ACTION=$1
STEP=5

get_volume() {
    pamixer --get-volume
}

get_mute_status() {
    pamixer --get-mute
}

volume_notification() {
    volume=$(get_volume)
    muted=$(get_mute_status)
    
    if [ "$muted" = "true" ]; then
        icon="audio-volume-muted"
        text="Muted"
    else
        if [ "$volume" -eq 0 ]; then
            icon="audio-volume-muted"
            text="Volume: $volume%"
        elif [ "$volume" -lt 30 ]; then
            icon="audio-volume-low"
            text="Volume: $volume%"
        elif [ "$volume" -lt 70 ]; then
            icon="audio-volume-medium"
            text="Volume: $volume%"
        else
            icon="audio-volume-high"
            text="Volume: $volume%"
        fi
    fi
    
    # Create a progress bar
    progress=""
    bar_length=20
    filled_length=$((volume * bar_length / 100))
    
    for ((i=0; i<filled_length; i++)); do
        progress+="■"
    done
    
    for ((i=filled_length; i<bar_length; i++)); do
        progress+="□"
    done
    
    notify-send -c volume -u low -i "$icon" "$text" "$progress" -t 1000 -h int:value:"$volume"
}

case $ACTION in
    "--inc")
        pamixer --increase $STEP
        volume_notification
        ;;
    "--dec")
        pamixer --decrease $STEP
        volume_notification
        ;;
    "--toggle")
        pamixer --toggle-mute
        volume_notification
        ;;
    "--toggle-mic")
        pamixer --default-source --toggle-mute
        
        if $(pamixer --default-source --get-mute); then
            notify-send -c volume -u low -i "microphone-disabled" "Microphone Muted" -t 1000
        else
            notify-send -c volume -u low -i "microphone-sensitivity-high" "Microphone Unmuted" -t 1000
        fi
        ;;
    *)
        echo "Usage: $0 {--inc|--dec|--toggle|--toggle-mic}"
        exit 1
        ;;
esac
