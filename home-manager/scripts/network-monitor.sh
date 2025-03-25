#!/usr/bin/env bash

# Network monitor script to show notifications for network events
# To be run as a systemd service

PREV_STATE=""
CHECK_INTERVAL=5

# Icons
ICON_CONNECTED="network-wireless"
ICON_DISCONNECTED="network-wireless-disconnected"
ICON_WIRED="network-wired"

check_network() {
    # Check if connected to any network
    if nmcli -t -f STATE g | grep -q "connected"; then
        CURRENT_STATE="connected"
        
        # Get connection details
        CONNECTION_INFO=$(nmcli -t -f NAME,TYPE,DEVICE c show --active | head -n1)
        NAME=$(echo "$CONNECTION_INFO" | cut -d: -f1)
        TYPE=$(echo "$CONNECTION_INFO" | cut -d: -f2)
        DEVICE=$(echo "$CONNECTION_INFO" | cut -d: -f3)
        
        # Get IP address
        IP=$(ip -4 addr show dev "$DEVICE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1)
        
        # Detect connection type
        if [[ "$TYPE" == *"wireless"* ]]; then
            ICON="$ICON_CONNECTED"
            STRENGTH=$(nmcli -f IN-USE,SIGNAL dev wifi | grep "\*" | awk '{print $2}')
            TYPE_TEXT="Wi-Fi"
            DETAILS="Network: $NAME\nSignal: $STRENGTH%\nIP: $IP"
        else
            ICON="$ICON_WIRED"
            TYPE_TEXT="Wired"
            DETAILS="Network: $NAME\nIP: $IP"
        fi
    else
        CURRENT_STATE="disconnected"
        ICON="$ICON_DISCONNECTED"
        TYPE_TEXT="No Connection"
        DETAILS="No network connection available"
    fi
    
    # Notify on state change
    if [ "$CURRENT_STATE" != "$PREV_STATE" ]; then
        if [ "$CURRENT_STATE" = "connected" ]; then
            notify-send -c network -u normal -i "$ICON" "Network Connected" "Connected to $TYPE_TEXT\n$DETAILS"
        else
            notify-send -c network -u normal -i "$ICON" "Network Disconnected" "Network connection lost"
        fi
        PREV_STATE="$CURRENT_STATE"
    fi
}

# Run once immediately
check_network

# Then monitor continuously
while true; do
    sleep $CHECK_INTERVAL
    check_network
done
