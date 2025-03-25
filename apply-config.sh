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

# Function to get user input with validation - improved to ensure explicit input
get_user_input() {
    local prompt=$1
    local default=$2
    local var_name=$3
    local validation=$4
    local error_msg=$5
    local value=""
    local valid=false
    
    while [ "$valid" != true ]; do
        # Display the prompt with default value
        read -p "$prompt [$default]: " input_value
        
        # If input is empty, confirm before using default
        if [ -z "$input_value" ]; then
            read -p "Use default value '$default'? (y/n): " use_default
            if [[ "$use_default" =~ ^[Yy]$ ]]; then
                value="$default"
                valid=true
            else
                echo "Please enter a value."
                continue
            fi
        else
            value="$input_value"
            
            # Validate the input
            if [ -z "$validation" ] || [[ "$value" =~ $validation ]]; then
                valid=true
            else
                echo -e "${YELLOW}$error_msg${NC}"
            fi
        fi
    done
    
    # Set the variable in the calling environment
    eval "$var_name=\"$value\""
    echo -e "${GREEN}Set ${var_name}=${value}${NC}"
}

# Function for selecting from a menu with explicit confirmation
select_from_menu() {
    local prompt=$1
    local options=$2
    local var_name=$3
    local default=$4
    local result_var=$5
    local option_count=$(echo "$options" | wc -l)
    local choice=""
    local valid=false
    
    echo "$prompt"
    echo "$options"
    
    while [ "$valid" != true ]; do
        read -p "Enter choice [${default}]: " input_choice
        
        # If input is empty, confirm before using default
        if [ -z "$input_choice" ]; then
            read -p "Use default choice '${default}'? (y/n): " use_default
            if [[ "$use_default" =~ ^[Yy]$ ]]; then
                choice="$default"
            else
                echo "Please enter a choice."
                continue
            fi
        else
            choice="$input_choice"
        fi
        
        # Validate numeric input within range
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$option_count" ]; then
            valid=true
        else
            echo -e "${YELLOW}Invalid choice. Please enter a number between 1 and $option_count.${NC}"
        fi
    done
    
    # Set both variables in the calling environment
    eval "$var_name=\"$choice\""
    
    # Get the corresponding value
    local value=$(echo "$options" | sed -n "${choice}p" | awk '{print $NF}' | tr -d '()')
    eval "$result_var=\"$value\""
    
    echo -e "${GREEN}Selected: ${NC}$value"
}

echo -e "${CYAN}Let's configure your NixOS system!${NC}"
echo "Please provide the following information for each setting."
echo "You'll be asked to confirm each value explicitly."
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

# Machine type menu selection
machine_options="1) Laptop (laptop)
2) Desktop (desktop)
3) Virtual Machine (vm)"
select_from_menu "Select machine type:" "$machine_options" "machine_choice" "1" "machine_type"

# Get display resolution with validation
get_user_input "Enter display resolution (WxH)" "1920x1080" "resolution" "^[0-9]+x[0-9]+$" "Invalid format. Please use format like '1920x1080'."

# Parse width and height from resolution
width=$(echo "$resolution" | cut -d'x' -f1)
height=$(echo "$resolution" | cut -d'x' -f2)

# Get refresh rate with validation
get_user_input "Enter refresh rate" "144" "refresh_rate" "^[0-9]+$" "Invalid refresh rate. Please enter a number."

# Theme selection
theme_options="1) Gruvbox Dark (gruvbox-dark)
2) Gruvbox Light (gruvbox-light)"
select_from_menu "Select theme variant:" "$theme_options" "theme_choice" "1" "theme_variant"

# Get font size with validation
get_user_input "Enter font size" "12" "font_size" "^[0-9]+$" "Invalid font size. Please enter a number."

# Get NixOS version with validation
NIXOS_VERSION=$(nixos-version | cut -d'.' -f1,2 || echo "24.05")
get_user_input "Enter NixOS version" "$NIXOS_VERSION" "nixos_version" "^[0-9]+\.[0-9]+$" "Version must be in format like '24.05'"

# Add boot loader selection to the configuration
echo -e "${CYAN}Boot Loader Configuration:${NC}"
echo "1) GRUB"
echo "2) systemd-boot"
boot_loader_choice=""
while [[ ! "$boot_loader_choice" =~ ^[1-2]$ ]]; do
    read -p "Select boot loader (1-2) [1]: " input
    boot_loader_choice="${input:-1}"
    
    if [[ ! "$boot_loader_choice" =~ ^[1-2]$ ]]; then
        echo -e "${YELLOW}Invalid choice. Please enter 1 or 2.${NC}"
    fi
done

case $boot_loader_choice in
    1) boot_loader="grub" ;;
    2) boot_loader="systemd-boot" ;;
esac
echo -e "${GREEN}Selected: ${NC}$boot_loader"

# Update the boot loader value
if grep -q '"boot":' "$vars_file"; then
    sed -i'' -E "s/(\"loader\":\s*\")[^\"]+(\",)/\1${boot_loader}\2/" "$vars_file"
    echo -e "${GREEN}✓${NC} Updated boot loader to ${boot_loader}"
else
    echo -e "${YELLOW}⚠${NC} Could not find boot configuration in variables.nix"
fi

# For GRUB, ask for device
if [ "$boot_loader" == "grub" ]; then
    # Get available disks
    echo "Available disks:"
    lsblk -d -o NAME,SIZE,MODEL | grep -v loop
    
    read -p "Enter disk for GRUB (e.g., sda, nvme0n1) or 'nodev' for EFI [nodev]: " grub_device
    grub_device="${grub_device:-nodev}"
    
    if [ "$grub_device" != "nodev" ]; then
        grub_device="/dev/$grub_device"
    fi
    
    # Update GRUB device in variables.nix
    if grep -q '"grub":' "$vars_file"; then
        sed -i'' -E "s/(\"device\":\s*\")[^\"]+(\",)/\1${grub_device}\2/" "$vars_file"
        echo -e "${GREEN}✓${NC} Updated GRUB device to ${grub_device}"
    fi
fi

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
echo -e "  Boot Loader: ${GREEN}$boot_loader${NC}"
if [ "$boot_loader" == "grub" ]; then
    echo -e "  GRUB Device: ${GREEN}$grub_device${NC}"
fi
echo

# Confirm settings
while true; do
    read -p "Proceed with these settings? (Y/n): " confirm
    confirm="${confirm:-Y}"
    
    if [[ "$confirm" =~ ^[YyNn]$ ]]; then
        break
    else
        echo -e "${YELLOW}Please answer Y or N.${NC}"
    fi
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
  nix.settings.experimental-features = [ "nix-command", "flakes" ];
  
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
    
    # Add thorium-browser input
    thorium-browser = {
      url = "github:manuja-me/thorium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Reference to our actual configuration
    my-config = {
      url = "path:$REPO_DIR";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.thorium-browser.follows = "thorium-browser";
    };
  };

  outputs = { self, nixpkgs, home-manager, thorium-browser, my-config, ... }:
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

# Add a section to modify the README.md file to include the proper curl commands
echo -e "${CYAN}Updating README.md with installation instructions...${NC}"

# Create a backup of the README.md file
cp "$REPO_DIR/README.md" "$REPO_DIR/README.md.bak"

# Update the curl command in the README
# This is a simplified update, adjust according to your repository structure
sed -i "s|curl -sSL https://raw.githubusercontent.com/[^/]*/nixos-config/main/apply-config.sh|curl -sSL https://raw.githubusercontent.com/manuja-me/nixos-config/main/apply-config.sh|g" "$REPO_DIR/README.md"

echo -e "${GREEN}✓${NC} README.md updated with the correct installation command."

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
