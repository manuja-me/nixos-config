#!/usr/bin/env bash

# Enhanced network speed monitoring script
# Shows upload/download speeds with human-readable formatting

# Detects active network interface automatically
get_active_interface() {
    # Try to find the most active interface
    ACTIVE_INTERFACE=$(ip -o -4 route show to default | awk '{print $5}' | head -n1)
    
    if [ -z "$ACTIVE_INTERFACE" ]; then
        # Fall back to checking common interface names
        for interface in eth0 wlan0 enp0s3 wlp2s0 $(ip -o -4 addr | awk '{print $2}' | cut -d':' -f1 | grep -v lo); do
            if [ -d "/sys/class/net/$interface" ] && [ "$(cat /sys/class/net/$interface/operstate)" = "up" ]; then
                ACTIVE_INTERFACE="$interface"
                break
            fi
        done
    fi
    
    echo "$ACTIVE_INTERFACE"
}

# Convert bytes to human-readable format
format_speed() {
    local bytes=$1
    local precision=2
    
    if [ "$bytes" -lt 1024 ]; then
        echo "${bytes} B/s"
    elif [ "$bytes" -lt 1048576 ]; then
        echo "$(printf "%.${precision}f" "$(echo "scale=${precision}; ${bytes}/1024" | bc)") KB/s"
    else
        echo "$(printf "%.${precision}f" "$(echo "scale=${precision}; ${bytes}/1048576" | bc)") MB/s"
    fi
}

# Main monitoring function
monitor_speed() {
    local interface="$1"
    local interval="$2"
    
    if [ -z "$interface" ]; then
        interface=$(get_active_interface)
        if [ -z "$interface" ]; then
            echo '{"text": "No network", "tooltip": "No active network interface found", "class": "disconnected"}'
            exit 1
        fi
    fi
    
    # Get initial values
    local rx1=$(cat /sys/class/net/$interface/statistics/rx_bytes)
    local tx1=$(cat /sys/class/net/$interface/statistics/tx_bytes)
    
    # Sleep for the interval
    sleep $interval
    
    # Get final values
    local rx2=$(cat /sys/class/net/$interface/statistics/rx_bytes)
    local tx2=$(cat /sys/class/net/$interface/statistics/tx_bytes)
    
    # Calculate speeds
    local rx_speed=$(($rx2 - $rx1))
    local tx_speed=$(($tx2 - $tx1))
    local rx_speed_per_sec=$(($rx_speed / $interval))
    local tx_speed_per_sec=$(($tx_speed / $interval))
    
    # Format speeds for display
    local rx_human=$(format_speed $rx_speed_per_sec)
    local tx_human=$(format_speed $tx_speed_per_sec)
    
    # Determine class for CSS styling
    local class="normal"
    if [ "$rx_speed_per_sec" -gt "$tx_speed_per_sec" ]; then
        class="down"
    elif [ "$tx_speed_per_sec" -gt "$rx_speed_per_sec" ]; then
        class="up"
    fi
    
    # Get additional network info for tooltip
    local ip_addr=$(ip -4 addr show dev $interface | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1)
    local mac_addr=$(cat /sys/class/net/$interface/address)
    local connection_type=""
    
    if [[ "$interface" == wl* ]] || [[ "$interface" == wlan* ]]; then
        connection_type="Wireless"
        local signal=$(iwconfig $interface 2>/dev/null | grep -i quality | awk '{print $2}' | cut -d'=' -f2 | cut -d'/' -f1)
        local total=$(iwconfig $interface 2>/dev/null | grep -i quality | awk '{print $2}' | cut -d'/' -f2)
        
        if [ ! -z "$signal" ] && [ ! -z "$total" ]; then
            local signal_percent=$((signal * 100 / total))
            connection_type="$connection_type (Signal: $signal_percent%)"
        fi
    else
        connection_type="Wired"
    fi
    
    # Create JSON output for Waybar
    echo "{
        \"text\": \"▼ $rx_human ▲ $tx_human\",
        \"tooltip\": \"Interface: $interface ($connection_type)\\nIP: $ip_addr\\nMAC: $mac_addr\\nDownload: $rx_human\\nUpload: $tx_human\",
        \"class\": \"$class\"
    }"
}

# Default interval is 1 second
INTERVAL=${1:-1}
INTERFACE=${2:-$(get_active_interface)}

while true; do
    monitor_speed "$INTERFACE" "$INTERVAL"
done
