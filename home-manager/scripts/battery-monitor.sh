#!/usr/bin/env bash

# Battery monitor script to show notifications for power events
# To be run as a systemd service

BATTERY_PATH="/sys/class/power_supply/BAT0"
PREV_STATUS=""
CRITICAL_LEVEL=10
LOW_LEVEL=20

# Icons
ICON_CHARGING="battery-charging"
ICON_DISCHARGING="battery-discharging"
ICON_LOW="battery-low"
ICON_CRITICAL="battery-caution"
ICON_FULL="battery-full"

check_battery() {
    # Check if battery exists
    if [ ! -d "$BATTERY_PATH" ]; then
        return
    fi

    # Get battery status
    STATUS=$(cat "$BATTERY_PATH/status")
    CAPACITY=$(cat "$BATTERY_PATH/capacity")

    # Status change notifications
    if [ "$STATUS" != "$PREV_STATUS" ]; then
        if [ "$STATUS" = "Charging" ]; then
            notify-send -c power -u normal -i "$ICON_CHARGING" "Battery Charging" "Battery is now charging ($CAPACITY%)"
        elif [ "$STATUS" = "Discharging" ]; then
            notify-send -c power -u normal -i "$ICON_DISCHARGING" "Battery Discharging" "Battery is now discharging ($CAPACITY%)"
        elif [ "$STATUS" = "Full" ]; then
            notify-send -c power -u normal -i "$ICON_FULL" "Battery Full" "Battery is fully charged"
        fi
        PREV_STATUS="$STATUS"
    fi

    # Low/Critical battery warnings when discharging
    if [ "$STATUS" = "Discharging" ]; then
        if [ "$CAPACITY" -le "$CRITICAL_LEVEL" ]; then
            notify-send -c power -u critical -i "$ICON_CRITICAL" "Battery Critical" "Battery level is critically low ($CAPACITY%)\nPlease connect charger immediately!"
        elif [ "$CAPACITY" -le "$LOW_LEVEL" ]; then
            notify-send -c power -u normal -i "$ICON_LOW" "Battery Low" "Battery level is low ($CAPACITY%)"
        fi
    fi
}

# Run once immediately
check_battery

# Then monitor continuously
while true; do
    sleep 60
    check_battery
done
