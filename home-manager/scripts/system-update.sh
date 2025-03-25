#!/usr/bin/env bash

# System update script with notifications
# To be used with nixos-rebuild and home-manager

ACTION=$1
REBOOT_AFTER=$2

notify_start() {
    notify-send -c system -u normal -i "system-software-update" \
        "System Update Started" "Starting $ACTION of your system..."
}

notify_finish() {
    local exit_code=$1
    if [ $exit_code -eq 0 ]; then
        notify-send -c system -u normal -i "system-software-update" \
            "System Update Complete" "Successfully completed $ACTION of your system."
        
        if [ "$REBOOT_AFTER" = "reboot" ]; then
            notify-send -c system -u critical -i "system-restart" \
                "System Reboot" "System will reboot in 30 seconds..." -t 29000
            sleep 30
            sudo reboot
        fi
    else
        notify-send -c system -u critical -i "dialog-error" \
            "System Update Failed" "Failed to $ACTION your system. Check the logs for details."
    fi
}

case $ACTION in
    "switch")
        notify_start
        sudo nixos-rebuild switch --flake .#default
        exit_code=$?
        notify_finish $exit_code
        ;;
    "boot")
        notify_start
        sudo nixos-rebuild boot --flake .#default
        exit_code=$?
        notify_finish $exit_code
        ;;
    "home")
        notify_start
        home-manager switch --flake .#default
        exit_code=$?
        notify_finish $exit_code
        ;;
    "full")
        notify_start
        notify-send -c system -u normal -i "system-software-update" \
            "Full System Update" "Updating flake inputs..."
        
        nix flake update
        flake_update_code=$?
        
        if [ $flake_update_code -eq 0 ]; then
            notify-send -c system -u normal -i "system-software-update" \
                "Full System Update" "Rebuilding NixOS..."
            
            sudo nixos-rebuild switch --flake .#default
            nixos_code=$?
            
            if [ $nixos_code -eq 0 ]; then
                notify-send -c system -u normal -i "system-software-update" \
                    "Full System Update" "Updating home-manager configuration..."
                
                home-manager switch --flake .#default
                home_code=$?
                
                if [ $home_code -eq 0 ]; then
                    notify-send -c system -u normal -i "system-software-update" \
                        "Full System Update Complete" "Successfully updated your entire system."
                    
                    if [ "$REBOOT_AFTER" = "reboot" ]; then
                        notify-send -c system -u critical -i "system-restart" \
                            "System Reboot" "System will reboot in 30 seconds..." -t 29000
                        sleep 30
                        sudo reboot
                    fi
                else
                    notify-send -c system -u critical -i "dialog-error" \
                        "Home-Manager Update Failed" "Failed to update home-manager configuration."
                fi
            else
                notify-send -c system -u critical -i "dialog-error" \
                    "NixOS Update Failed" "Failed to rebuild NixOS."
            fi
        else
            notify-send -c system -u critical -i "dialog-error" \
                "Flake Update Failed" "Failed to update flake inputs."
        fi
        ;;
    *)
        echo "Usage: $0 {switch|boot|home|full} [reboot]"
        exit 1
        ;;
esac
