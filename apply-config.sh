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

# Check for required commands and install them if needed
needed_pkgs=""
for cmd in git sed curl; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${YELLOW}Required command '$cmd' not found. Will install it.${NC}"
        needed_pkgs="$needed_pkgs $cmd"
    fi
done

if [ -n "$needed_pkgs" ]; then
    echo -e "${CYAN}Installing required packages:${NC}$needed_pkgs"
    nix-env -iA nixos.git nixos.gnused nixos.curl
fi

# Get the actual user who is running the script with sudo
ACTUAL_USER=${SUDO_USER:-$(whoami)}

# Backup original NixOS configuration
echo -e "${CYAN}Backing up original NixOS configuration...${NC}"
timestamp=$(date +%Y%m%d%H%M%S)
backup_dir="/etc/nixos.backup.$timestamp"
mkdir -p "$backup_dir"
cp -r /etc/nixos/* "$backup_dir/"
echo -e "${GREEN}✓${NC} Original configuration backed up to $backup_dir"

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

# Check if repository already exists
REPO_DIR="/home/$ACTUAL_USER/nixos-config"
if [ -d "$REPO_DIR" ]; then
    echo -e "${YELLOW}Repository already exists at $REPO_DIR${NC}"
    read -p "Would you like to use it? (Y/n): " use_existing
    use_existing=${use_existing:-Y}
    
    if [[ "$use_existing" =~ ^[Yy]$ ]]; then
        cd "$REPO_DIR"
    else
        read -p "Do you want to delete the existing repository and clone a fresh copy? (y/N): " delete_repo
        delete_repo=${delete_repo:-N}
        
        if [[ "$delete_repo" =~ ^[Yy]$ ]]; then
            echo "Removing existing repository..."
            rm -rf "$REPO_DIR"
            clone_repo=true
        else
            echo "Please manually handle the repository and run this script again."
            exit 0
        fi
    fi
else
    clone_repo=true
fi

# Clone repository if needed
if [ "$clone_repo" = true ]; then
    echo -e "${CYAN}Cloning nixos-config repository...${NC}"
    git clone https://github.com/manuja-me/nixos-config.git "$REPO_DIR"
    cd "$REPO_DIR"
    echo -e "${GREEN}✓${NC} Repository cloned to $REPO_DIR"
    
    # Fix ownership of the cloned repository
    chown -R $ACTUAL_USER:$ACTUAL_USER "$REPO_DIR"
fi

# Ensure we're working with the right file paths
vars_file="$REPO_DIR/variables.nix"

if [ ! -f "$vars_file" ]; then
    echo -e "${RED}Error: variables.nix file not found at $vars_file${NC}"
    echo "Please check that the repository was cloned correctly."
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
        read -p "$prompt [$default]: " input
        value="${input:-$default}"
        
        if [ -z "$validation" ] || [[ "$value" =~ $validation ]]; then
            valid=true
        else
            echo -e "${YELLOW}$error_msg${NC}"
        fi
    done
    
    # Set the variable in the calling environment
    eval "$var_name=\"$value\""
}

echo -e "${CYAN}Let's configure your NixOS system!${NC}"
echo "Please provide the following information:"
echo

# Get hostname with validation
get_user_input "Enter hostname" "nixos" "hostname" "^[a-zA-Z0-9-]+$" "Hostname must contain only letters, numbers, and hyphens."

# Get username with validation
default_user=${SUDO_USER:-manuja}
get_user_input "Enter username" "$default_user" "username" "^[a-z_][a-z0-9_-]*$" "Username must start with a letter and contain only lowercase letters, numbers, underscores, and hyphens."

# Get timezone with validation
get_user_input "Enter timezone" "Asia/Colombo" "timezone"

# Validate timezone
if [ -n "$timezone" ] && ! find /usr/share/zoneinfo -type f -name "*" | grep -q "$timezone"; then
    echo -e "${YELLOW}Warning: Timezone $timezone may not be valid. Using Asia/Colombo instead.${NC}"
    timezone="Asia/Colombo"
fi

# Machine type selection with explicit prompt
echo "Select machine type:"
echo "1) Laptop"
echo "2) Desktop"
echo "3) Virtual Machine"
machine_choice=""
while [[ ! "$machine_choice" =~ ^[1-3]$ ]]; do
    read -p "Enter choice (1-3) [1]: " input
    machine_choice="${input:-1}"
    
    if [[ ! "$machine_choice" =~ ^[1-3]$ ]]; then
        echo -e "${YELLOW}Invalid choice. Please enter 1, 2, or 3.${NC}"
    fi
done

case $machine_choice in
    1) machine_type="laptop" ;;
    2) machine_type="desktop" ;;
    3) machine_type="vm" ;;
esac
echo -e "${GREEN}Selected: ${NC}$machine_type"

# Display settings with validation
resolution=""
while [[ ! "$resolution" =~ ^[0-9]+x[0-9]+$ ]]; do
    read -p "Enter display resolution (WxH) [1920x1080]: " input
    resolution="${input:-1920x1080}"
    
    if [[ ! "$resolution" =~ ^[0-9]+x[0-9]+$ ]]; then
        echo -e "${YELLOW}Invalid format. Please use format like '1920x1080'.${NC}"
    fi
done
width=$(echo $resolution | cut -d'x' -f1)
height=$(echo $resolution | cut -d'x' -f2)

refresh_rate=""
while [[ ! "$refresh_rate" =~ ^[0-9]+$ ]]; do
    read -p "Enter refresh rate [144]: " input
    refresh_rate="${input:-144}"
    
    if [[ ! "$refresh_rate" =~ ^[0-9]+$ ]]; then
        echo -e "${YELLOW}Invalid refresh rate. Please enter a number.${NC}"
    fi
done

# Theme settings with explicit prompt
echo "Select theme variant:"
echo "1) Gruvbox Dark"
echo "2) Gruvbox Light"
theme_choice=""
while [[ ! "$theme_choice" =~ ^[1-2]$ ]]; do
    read -p "Enter choice (1-2) [1]: " input
    theme_choice="${input:-1}"
    
    if [[ ! "$theme_choice" =~ ^[1-2]$ ]]; then
        echo -e "${YELLOW}Invalid choice. Please enter 1 or 2.${NC}"
    fi
done

case $theme_choice in
    1) theme_variant="gruvbox-dark" ;;
    2) theme_variant="gruvbox-light" ;;
esac
echo -e "${GREEN}Selected: ${NC}$theme_variant"

font_size=""
while [[ ! "$font_size" =~ ^[0-9]+$ ]]; do
    read -p "Enter font size [12]: " input
    font_size="${input:-12}"
    
    if [[ ! "$font_size" =~ ^[0-9]+$ ]]; then
        echo -e "${YELLOW}Invalid font size. Please enter a number.${NC}"
    fi
done

# Get NixOS version with validation
NIXOS_VERSION=$(nixos-version | cut -d'.' -f1,2 || echo "24.05")
get_user_input "Enter NixOS version" "$NIXOS_VERSION" "nixos_version" "^[0-9]+\.[0-9]+$" "Version must be in format like '24.05'"

# Show summary and ask for confirmation
echo
echo -e "${CYAN}Configuration Summary:${NC}"
echo -e "  Hostname: ${GREEN}$hostname${NC}"
echo -e "  Username: ${GREEN}$username${NC}"
echo -e "  Timezone: ${GREEN}$timezone${NC}"
echo -e "  Machine Type: ${GREEN}$machine_type${NC}"
echo -e "  Display: ${GREEN}${width}x${height} @ ${refresh_rate}Hz${NC}"
echo -e "  Theme: ${GREEN}$theme_variant${NC} (Font size: ${GREEN}${font_size}pt${NC})"
echo -e "  NixOS Version: ${GREEN}$nixos_version${NC}"
echo

confirm=""
while [[ ! "$confirm" =~ ^[YyNn]$ ]]; do
    read -p "Proceed with these settings? (Y/n): " input
    confirm="${input:-Y}"
done

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
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

# Link configurations to /etc/nixos
echo -e "${CYAN}Linking configuration files to /etc/nixos...${NC}"
echo "Creating a symbolic link from your nixos-config to /etc/nixos/configuration.nix"

# Setup flake-enabled NixOS configuration
cat > /etc/nixos/configuration.nix <<EOF
# This is a minimal configuration that imports the flake-based configuration
{ ... }: {
  imports = [ ];
  
  # Enable experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Add git for flake usage
  environment.systemPackages = with pkgs; [
    git
    curl
  ];
  
  # This is a helper configuration that will be replaced by the flake
  system.stateVersion = "$nixos_version";
}
EOF

# Create a flake.nix in /etc/nixos that imports our configuration
cat > /etc/nixos/flake.nix <<EOF
{
  description = "NixOS system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-$nixos_version";
    home-manager.url = "github:nix-community/home-manager/release-$nixos_version";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    
    # Reference to our actual configuration
    my-config = {
      url = "path:$REPO_DIR";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, home-manager, my-config, ... }:
    my-config.outputs;
}
EOF

echo -e "${GREEN}✓${NC} NixOS configuration setup to use flakes from $REPO_DIR"

# Install home-manager
echo -e "${CYAN}Setting up Home Manager...${NC}"
nix-channel --add https://github.com/nix-community/home-manager/archive/release-${nixos_version}.tar.gz home-manager
nix-channel --update

# Apply system configuration
echo -e "${CYAN}Rebuilding NixOS system configuration...${NC}"
echo "This may take a while depending on your system."
echo "Please be patient."

if ! nixos-rebuild switch --flake /etc/nixos#default; then
    echo -e "${RED}Error: nixos-rebuild failed${NC}"
    echo "Please check the error messages above and fix any issues in your configuration."
    
    echo -e "${YELLOW}Rolling back to original configuration...${NC}"
    cp -r "$backup_dir"/* /etc/nixos/
    nixos-rebuild switch
    
    exit 1
else
    echo -e "${GREEN}✓${NC} System configuration applied successfully."
fi

# Create the user if it doesn't exist
if ! id "$username" &>/dev/null; then
    echo -e "${CYAN}Creating user $username...${NC}"
    useradd -m -G wheel -s /run/current-system/sw/bin/zsh "$username"
    passwd "$username"
fi

# Run home-manager as the specified user
echo -e "${CYAN}Applying Home Manager configuration for $username...${NC}"
su - "$username" -c "mkdir -p ~/.config/home-manager"
su - "$username" -c "home-manager switch --flake /etc/nixos#default || echo 'Home-manager failed, but we will continue.'"

echo
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}                 Configuration Complete!                      ${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo
echo "Your NixOS system has been configured with your settings."
echo "The original configuration is backed up at $backup_dir"
echo "Your custom configuration is at $REPO_DIR"
echo 
echo -e "${CYAN}What's next?${NC}"
echo "1. Review your configuration in $vars_file"
echo "2. Customize programs in $REPO_DIR/home-manager/programs/"
echo "3. Learn more about NixOS and Home Manager in the documentation"
echo "4. To update your system in the future, run: nixos-rebuild switch --flake /etc/nixos#default"
echo
echo "Enjoy your new NixOS system!"

read -p "Would you like to reboot now to apply all changes? (y/N): " reboot_now
reboot_now=${reboot_now:-N}

if [[ "$reboot_now" =~ ^[Yy]$ ]]; then
    echo "Rebooting system..."
    reboot
fi
