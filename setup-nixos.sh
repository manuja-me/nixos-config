#!/usr/bin/env bash
set -eo pipefail

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check if running with sudo/root privileges
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}This script requires administrative privileges to modify system files.${NC}"
    echo -e "Please run with sudo: ${CYAN}sudo $0 $*${NC}"
    exit 1
fi

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

# Enable flakes if not already enabled
if ! grep -q "experimental-features.*flakes" /etc/nixos/configuration.nix; then
    echo -e "${YELLOW}Flakes are not enabled in your system configuration.${NC}"
    echo "Adding flakes configuration to /etc/nixos/configuration.nix..."
    
    # Add flakes configuration to the existing file
    sed -i '/^{/a \  nix.settings.experimental-features = [ "nix-command", "flakes" ];' /etc/nixos/configuration.nix
    sed -i '/environment.systemPackages/a \    git\n    curl' /etc/nixos/configuration.nix 2>/dev/null || \
    sed -i '/^{/a \  environment.systemPackages = with pkgs; [\n    git\n    curl\n  ];' /etc/nixos/configuration.nix
    
    echo -e "${CYAN}Rebuilding NixOS to enable flakes...${NC}"
    nixos-rebuild switch
    
    echo -e "${GREEN}✓${NC} Flakes are now enabled on your system."
else
    echo -e "${GREEN}✓${NC} Flakes are already enabled on your system."
fi

# Function to get user input with validation
get_user_input() {
    local prompt=$1
    local default=$2
    local var_name=$3
    local validation=$4
    local error_msg=$5
    local value=""
    local valid=false
    
    while [ "$valid" != true ]; do
        read -p "$prompt [$default]: " input_value
        if [ -z "$input_value" ]; then
            value="$default"
        else
            value="$input_value"
        fi
        
        if [ -z "$validation" ] || [[ "$value" =~ $validation ]]; then
            valid=true
        else
            echo -e "${YELLOW}$error_msg${NC}"
        fi
    done
    
    eval "$var_name=\"$value\""
    echo -e "${GREEN}Set ${var_name}=${value}${NC}"
}

# Prompt for user inputs
get_user_input "Enter hostname" "nixos" "hostname" "^[a-zA-Z0-9-]+$" "Hostname must contain only letters, numbers, and hyphens."
get_user_input "Enter username" "manuja" "username" "^[a-z_][a-z0-9_-]*$" "Username must start with a letter and contain only lowercase letters, numbers, underscores, and hyphens."
get_user_input "Enter timezone" "Asia/Colombo" "timezone" "" ""
get_user_input "Enter NixOS version" "$(nixos-version | cut -d'.' -f1,2)" "nixos_version" "^[0-9]+\.[0-9]+$" "Version must be in format like '24.05'."

# Clone the configuration repository
REPO_DIR="/home/$username/nixos-config"
if [ -d "$REPO_DIR" ]; then
    echo -e "${YELLOW}Repository already exists at $REPO_DIR${NC}"
    read -p "Do you want to delete the existing repository and clone a fresh copy? (y/N): " delete_repo
    delete_repo=${delete_repo:-N}
    if [[ "$delete_repo" =~ ^[Yy]$ ]]; then
        echo "Removing existing repository..."
        rm -rf "$REPO_DIR"
    else
        echo "Using the existing repository."
    fi
fi

if [ ! -d "$REPO_DIR" ]; then
    echo -e "${CYAN}Cloning nixos-config repository...${NC}"
    git clone https://github.com/manuja-me/nixos-config.git "$REPO_DIR"
    chown -R $username:users "$REPO_DIR"
    echo -e "${GREEN}✓${NC} Repository cloned to $REPO_DIR"
fi

# Update variables.nix with user inputs
vars_file="$REPO_DIR/variables.nix"
if [ -f "$vars_file" ]; then
    sed -i'' -E "s/(\"hostname\":\s*\")[^\"]*\"/\1${hostname}\"/" "$vars_file"
    sed -i'' -E "s/(\"username\":\s*\")[^\"]*\"/\1${username}\"/" "$vars_file"
    sed -i'' -E "s/(timezone\s*=\s*\")[^\"]*\"/\1${timezone}\"/" "$vars_file"
    echo -e "${GREEN}✓${NC} Updated variables.nix with user inputs."
else
    echo -e "${RED}Error: variables.nix file not found at $vars_file${NC}"
    exit 1
fi

# Link configuration to /etc/nixos
echo -e "${CYAN}Linking configuration files to /etc/nixos...${NC}"
ln -sf "$REPO_DIR/flake.nix" /etc/nixos/flake.nix
ln -sf "$REPO_DIR" /etc/nixos/configuration.nix

# Apply the configuration
echo -e "${CYAN}Applying NixOS configuration...${NC}"
nixos-rebuild switch --flake /etc/nixos#default

# Create the user if it doesn't exist
if ! id "$username" &>/dev/null; then
    echo -e "${CYAN}Creating user $username...${NC}"
    useradd -m -G wheel,users -s /run/current-system/sw/bin/zsh "$username"
    passwd "$username"
    chown -R $username:users /home/$username
    echo -e "${GREEN}✓${NC} User $username created."
fi

echo -e "${GREEN}NixOS configuration applied successfully!${NC}"
