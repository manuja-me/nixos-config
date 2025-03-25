#!/usr/bin/env bash
set -eo pipefail

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print header
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║             ${CYAN}NixOS Configuration Setup Tool${BLUE}             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo

# Check if running under NixOS
if [ ! -f /etc/nixos/configuration.nix ]; then
    echo -e "${RED}Error: This script must be run on a NixOS system.${NC}"
    echo "Please install NixOS first and then run this script."
    exit 1
fi

# Check for required commands
for cmd in git sed sudo; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}Error: Required command '$cmd' not found.${NC}"
        echo "Please install it first with 'nix-env -iA nixos.${cmd}'"
        exit 1
    fi
done

# Path to variables.nix file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
vars_file="${SCRIPT_DIR}/variables.nix"

if [ ! -f "$vars_file" ]; then
    echo -e "${RED}Error: variables.nix file not found at $vars_file${NC}"
    echo "Please run this script from the root of the nixos-config repository."
    exit 1
fi

# Function to update a value in variables.nix
update_var() {
    local var_name=$1
    local value=$2
    local pattern=$3

    if grep -q "$var_name" "$vars_file"; then
        sed -i'' -E "s|$pattern|$value\"|" "$vars_file"
        echo -e "${GREEN}✓${NC} Updated $var_name to $value"
    else
        echo -e "${YELLOW}⚠${NC} Could not find $var_name in variables.nix"
    fi
}

# Configure flakes if not already enabled
if ! grep -q "experimental-features" /etc/nixos/configuration.nix; then
    echo -e "${YELLOW}Flakes are not enabled in your system configuration.${NC}"
    read -p "Would you like to enable them now? (Y/n): " enable_flakes
    enable_flakes=${enable_flakes:-Y}
    
    if [[ "$enable_flakes" =~ ^[Yy]$ ]]; then
        echo "Adding flakes configuration to /etc/nixos/configuration.nix..."
        sudo sed -i '/^{/a \  nix.settings.experimental-features = [ "nix-command" "flakes" ];' /etc/nixos/configuration.nix
        echo "Rebuilding NixOS to enable flakes..."
        sudo nixos-rebuild switch
    else
        echo -e "${RED}Flakes are required for this configuration. Exiting.${NC}"
        exit 1
    fi
fi

echo -e "${CYAN}Let's configure your NixOS system!${NC}"
echo "Please provide the following information (press Enter for defaults):"
echo

# Get hostname
read -p "Enter hostname [nixos]: " input_hostname
hostname="${input_hostname:-nixos}"

# Get username
read -p "Enter username [manuja]: " input_username
username="${input_username:-manuja}"

# Get timezone with validation
read -p "Enter timezone [Asia/Colombo]: " input_timezone
timezone="${input_timezone:-Asia/Colombo}"

# Validate timezone
if [ -n "$timezone" ] && ! find /usr/share/zoneinfo -type f -name "*" | grep -q "$timezone"; then
    echo -e "${YELLOW}Warning: Timezone $timezone may not be valid. Using Asia/Colombo instead.${NC}"
    timezone="Asia/Colombo"
fi

# Machine type
echo "Select machine type:"
echo "1) Laptop (default)"
echo "2) Desktop"
echo "3) Virtual Machine"
read -p "Enter choice [1]: " machine_choice
machine_choice="${machine_choice:-1}"

case $machine_choice in
    1) machine_type="laptop" ;;
    2) machine_type="desktop" ;;
    3) machine_type="vm" ;;
    *) echo -e "${YELLOW}Invalid choice. Using laptop as default.${NC}"; machine_type="laptop" ;;
esac

# Display settings
read -p "Enter display resolution (WxH) [1920x1080]: " resolution
resolution="${resolution:-1920x1080}"
width=$(echo $resolution | cut -d'x' -f1)
height=$(echo $resolution | cut -d'x' -f2)

read -p "Enter refresh rate [144]: " refresh_rate
refresh_rate="${refresh_rate:-144}"

# Theme settings
echo "Select theme variant:"
echo "1) Gruvbox Dark (default)"
echo "2) Gruvbox Light"
read -p "Enter choice [1]: " theme_choice
theme_choice="${theme_choice:-1}"

case $theme_choice in
    1) theme_variant="gruvbox-dark" ;;
    2) theme_variant="gruvbox-light" ;;
    *) echo -e "${YELLOW}Invalid choice. Using Gruvbox Dark as default.${NC}"; theme_variant="gruvbox-dark" ;;
esac

read -p "Enter font size [12]: " font_size
font_size="${font_size:-12}"

# NixOS version
read -p "Enter NixOS version [24.11]: " input_version
nixos_version="${input_version:-24.11}"

# Show summary and ask for confirmation
echo
echo -e "${CYAN}Configuration Summary:${NC}"
echo "  Hostname: $hostname"
echo "  Username: $username"
echo "  Timezone: $timezone"
echo "  Machine Type: $machine_type"
echo "  Display: ${width}x${height} @ ${refresh_rate}Hz"
echo "  Theme: $theme_variant (Font size: ${font_size}pt)"
echo "  NixOS Version: $nixos_version"
echo

read -p "Proceed with these settings? (Y/n): " proceed
proceed=${proceed:-Y}

if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
    echo "Setup cancelled. No changes made."
    exit 0
fi

echo -e "${CYAN}Updating variables.nix with your settings...${NC}"

# Update variables.nix file with new values
update_var "hostname" "$hostname" '("hostname":\s*")[^"]*(")' 
update_var "username" "$username" '("username":\s*")[^"]*(")' 
update_var "timezone" "$timezone" '(timezone\s*=\s*")[^"]*(")' 
update_var "machineType" "$machine_type" '("machineType":\s*")[^"]*(")' 

# Update display settings
sed -i'' -E "s/(\"width\":\s*)[0-9]+/\1${width}/" "$vars_file"
sed -i'' -E "s/(\"height\":\s*)[0-9]+/\1${height}/" "$vars_file"
sed -i'' -E "s/(\"refreshRate\":\s*)[0-9]+/\1${refresh_rate}/" "$vars_file"

# Update theme settings
sed -i'' -E "s/(\"name\":\s*\")[^\"]+(\")$/\1${theme_variant}\2/" "$vars_file"
sed -i'' -E "s/(\"size\":\s*)[0-9]+/\1${font_size}/" "$vars_file"

echo -e "${GREEN}✓${NC} variables.nix updated successfully."

# Install home-manager if not already installed
if ! command -v home-manager &> /dev/null; then
    echo -e "${YELLOW}Home Manager not found. Installing...${NC}"
    nix-channel --add https://github.com/nix-community/home-manager/archive/release-${nixos_version}.tar.gz home-manager
    nix-channel --update
    nix-shell '<home-manager>' -A install
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to install Home Manager.${NC}"
        exit 1
    fi
fi

# Apply system configuration
echo -e "${CYAN}Rebuilding NixOS system configuration...${NC}"
echo "This may take a while depending on your system."
echo "Please be patient and enter your password when prompted."

if ! sudo nixos-rebuild switch --flake .#default; then
    echo -e "${RED}Error: nixos-rebuild failed${NC}"
    echo "Please check the error messages above and fix any issues in your configuration."
    read -p "Would you like to continue to home-manager setup anyway? (y/N): " continue_hm
    continue_hm=${continue_hm:-N}
    if [[ ! "$continue_hm" =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo -e "${GREEN}✓${NC} System configuration applied successfully."
fi

# Apply Home Manager configuration
echo -e "${CYAN}Applying Home Manager configuration...${NC}"
if ! home-manager switch --flake .#default; then
    echo -e "${RED}Error: home-manager switch failed${NC}"
    echo "Please check the error messages above and fix any issues in your configuration."
    exit 1
else
    echo -e "${GREEN}✓${NC} Home Manager configuration applied successfully."
fi

echo
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}                 Configuration Complete!                      ${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo
echo "Your NixOS system has been configured with your settings."
echo "You may need to log out and back in for all changes to take effect."
echo
echo -e "${CYAN}What's next?${NC}"
echo "1. Review your configuration in ${vars_file}"
echo "2. Customize programs in home-manager/programs/"
echo "3. Learn more about NixOS and Home Manager in the documentation"
echo
echo "Enjoy your new NixOS system!"

read -p "Would you like to reboot now to apply all changes? (y/N): " reboot_now
reboot_now=${reboot_now:-N}

if [[ "$reboot_now" =~ ^[Yy]$ ]]; then
    echo "Rebooting system..."
    sudo reboot
fi
