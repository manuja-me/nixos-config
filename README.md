# NixOS Configuration with Flakes and Home Manager

<!-- Interactive Header: Badges & Table of Contents -->
[![NixOS](https://img.shields.io/badge/NixOS-config--enabled-brightgreen)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Flakes-enabled-blue)](https://nixos.wiki/wiki/Flakes)
[![NixOS Unstable](https://img.shields.io/badge/NixOS-unstable-orange)](https://nixos.org)

**Table of Contents**
- [Overview](#overview)
- [Manual Installation on a Fresh NixOS System](#manual-installation-on-a-fresh-nixos-system)
- [Core Files](#core-files)
- [System Configuration](#system-configuration)
- [User Environment](#user-environment)
- [Keyboard Shortcuts and Aliases](#keyboard-shortcuts-and-aliases)
- [Directory Structure](#directory-structure)
- [Contributing](#contributing)

## Overview

This repository contains a modular NixOS configuration using flakes and Home Manager, designed to provide a reproducible and customizable system environment with a focus on consistency and organization.

> **✅ Configuration Status:** This configuration has been recently reviewed and all critical errors have been fixed. See [ACCURACY_SUMMARY.md](ACCURACY_SUMMARY.md) for details. The configuration now builds successfully and follows NixOS best practices.

## Manual Installation on a Fresh NixOS System

### Prerequisites

- A minimal NixOS installation (can be from a live USB)
- Internet connection
- Basic knowledge of command line usage

### Step-by-Step Installation

1. **First Boot and Initial Setup**

   After installing minimal NixOS and booting into it for the first time, you'll need to enable flakes since they aren't enabled by default:

   ```bash
   # Open your initial system configuration
   sudo nano /etc/nixos/configuration.nix
   ```

   Add these lines to your configuration file:
   ```nix
   { pkgs, ... }: {
     # Your existing config...
     
     # Enable flakes and nix commands
     nix.settings.experimental-features = [ "nix-command" "flakes" ];
     
     # Install essential tools
     environment.systemPackages = with pkgs; [
       git
       curl
       wget
       vim
     ];
   }
   ```

   Save the file (Ctrl+O, Enter, then Ctrl+X) and apply the changes:
   ```bash
   sudo nixos-rebuild switch
   ```

2. **Clone the Configuration Repository**

   Create a directory for the configuration and clone the repository:

   ```bash
   mkdir -p ~/nixos-setup
   cd ~/nixos-setup
   git clone https://github.com/manuja-me/nixos-config.git
   cd nixos-config
   ```

3. **Customize the Configuration**

   Before applying the configuration, you should customize it for your system:

   ```bash
   # Edit the variables file to set your username, hostname, etc.
   nano variables.nix
   ```

   Review and modify hardware-specific configuration:
   ```bash
   # For laptop installation
   nano hosts/machine-specific/laptop.nix
   
   # For desktop installation
   nano hosts/machine-specific/desktop.nix
   
   # For virtual machine installation
   nano hosts/machine-specific/vm.nix
   ```

4. **Make the Directory Available to NixOS**

   Create a symlink to make your configuration accessible to the NixOS system:

   ```bash
   sudo ln -sf $PWD /etc/nixos/nixos-config
   ```

5. **Install Home Manager**

   Home Manager needs to be installed for user-level configurations:

   ```bash
   # Create a temporary configuration to install home-manager
   cat > ~/home-manager-install.nix <<EOF
   {
     description = "Home Manager installer";
     inputs = {
       nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
       home-manager = {
         url = "github:nix-community/home-manager";
         inputs.nixpkgs.follows = "nixpkgs";
       };
     };
     outputs = { nixpkgs, home-manager, ... }: {
       packages.x86_64-linux.default = home-manager.defaultPackage.x86_64-linux;
     };
   }
   EOF
   
   # Install home-manager
   nix profile install ~/home-manager-install.nix
   ```

6. **Apply System Configuration**

   Apply the NixOS system configuration:

   ```bash
   # Apply the system configuration
   sudo nixos-rebuild switch --flake /etc/nixos/nixos-config#default
   ```

7. **Apply User Configuration**

   Now apply the Home Manager configuration for your user environment:

   ```bash
   # Apply the user-level configuration
   home-manager switch --flake /etc/nixos/nixos-config#default
   ```

8. **Reboot to Complete Installation**

   ```bash
   sudo reboot
   ```

### Troubleshooting Common Issues

1. **"error: flake 'path:/etc/nixos/nixos-config' does not exist"**
   - Ensure the symlink was created correctly: `ls -la /etc/nixos/nixos-config`
   - Try using the absolute path instead: `sudo nixos-rebuild switch --flake /home/yourusername/nixos-setup/nixos-config#default`

2. **"error: attribute 'defaultPackage' missing"**
   - Try installing home-manager with: 
     ```bash
     nix shell nixpkgs#home-manager --command home-manager switch --flake /etc/nixos/nixos-config#default
     ```

3. **Hardware detection issues**
   - Run `lspci` and `lsusb` to identify your hardware
   - Modify the appropriate file in `hosts/machine-specific/` to support your hardware

### Updating Your System

Once installed, updating your system is straightforward:

```bash
# Update flake inputs to latest versions
cd /etc/nixos/nixos-config
nix flake update

# Apply system updates
sudo nixos-rebuild switch --flake .#default

# Apply user environment updates
home-manager switch --flake .#default
```

### System Recovery

If something goes wrong, you can roll back to a previous generation:

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Roll back to previous generation
sudo nixos-rebuild switch --rollback
```

## Core Files

- **flake.nix**: The central entry point of the configuration.
  - Declares external dependencies (nixpkgs, home-manager)
  - Defines system configurations (NixOS) and user configurations (Home Manager)
  - Links all configuration modules together into cohesive outputs

- **flake.lock**: Auto-generated file that pins exact versions of all dependencies for reproducible builds.

- **variables.nix**: Contains shared variables used across configurations (usernames, hostnames, paths, theme settings, etc.).

## System Configuration (`hosts/`)

- **default.nix**: Base system configuration imported by flake.nix.
  - Sets up fundamental system properties
  - Imports machine-specific configurations

- **configuration.nix**: Main NixOS configuration.
  - Defines global system packages
  - Configures system-wide services
  - Sets up networking, bootloader, and other core system components

- **machine-specific/**: Hardware-specific configurations.
  - **laptop.nix**: Settings for laptop hardware (power management, touchpad, etc.)
  - **desktop.nix**: Optimized for desktop hardware with GPU support
  - **vm.nix**: Minimized configuration for virtual machines

## User Environment (`home-manager/`)

- **default.nix**: Primary Home Manager configuration.
  - Sets up the user environment basics
  - Imports and combines program and theme configurations

### Programs (`home-manager/programs/`)

- **default.nix**: Aggregates program-specific configurations.

- **sway/**: Window manager configuration.
  - **default.nix**: Integration with Home Manager
  - **config**: Raw configuration defining keybindings, workspaces, etc.

- **waybar/**: Status bar configuration.
  - **default.nix**: Integration with Home Manager and Alacritty

- **neovim/**: Editor configuration with LazyVim-like setup.
  - **default.nix**: Neovim setup with LSP support and GitHub Copilot

- **alacritty/**: Terminal emulator configuration.
  - **default.nix**: Terminal configuration with theming

### Theming (`home-manager/themes/` and `themes/`)

- **themes/gruvbox.nix**: Centralized Gruvbox color scheme definitions.
  - Used across all applications for consistent theming

- **home-manager/themes/default.nix**: User interface theming.
  - Applies consistent colors across applications
  - Imports from the centralized theme definition

- **home-manager/themes/colors.nix**: Theme mapping for Home Manager.
  - References the centralized color scheme

## External Applications

- **thorium-browser/**: Custom Chromium fork optimized for speed.
  - **flake.nix**: Declarative build and configuration

## Custom Extensions

- **modules/**: Custom NixOS modules for specialized functionality.
  - **default.nix**: Entry point for modules
  - **system/default.nix**: System-specific module implementations

- **overlays/**: Custom package modifications.
  - Extends or overrides packages from nixpkgs

- **pkgs/**: Custom package definitions.
  - Packages not available in nixpkgs or requiring customization

## System Features

- **Window Management**: Sway (Wayland-based tiling window manager)
- **Terminal**: Alacritty with JetBrainsMono Nerd Font (12pt)
- **Status Bar**: Waybar with custom styling
- **Text Editor**: Neovim with LazyVim-like keybindings and LSP support
- **File Browser**: Yazi terminal file manager
- **Web Browser**: Thorium Browser (Chromium fork)
- **Theme**: Gruvbox Dark with consistent application across all programs
- **Display**: Configured for 1920x1080 @ 144Hz

## Keyboard Shortcuts and Aliases

### Sway Window Manager Keybindings

| Keybinding                   | Action                                           |
|------------------------------|--------------------------------------------------|
| Mod+Shift+C                  | Reload Sway configuration                        |
| Mod+Shift+E                  | Exit Sway                                        |
| Mod+Left/Right/Up/Down       | Focus window in direction                        |
| Mod+Shift+Left/Right/Up/Down | Move window in direction                         |
| Mod+1-9                      | Switch to workspace 1-9                          |
| Mod+Shift+1-9                | Move window to workspace 1-9                     |
| Mod+F                        | Toggle fullscreen for focused window             |
| Mod+V                        | Split containers vertically                      |
| Mod+H                        | Split containers horizontally                    |
| Mod+R                        | Enter resize mode                                |
| Mod+Space                    | Toggle between tiling/floating                   |
| Mod+Shift+Space              | Toggle floating for focused window               |
| Print                        | Take screenshot (saved to ~/Pictures)            |
| Mod+Print                    | Take screenshot of active window                 |
| Mod+Shift+Print              | Take screenshot of selected area                 |


### ZSH Aliases and Shortcuts

| Alias/Shortcut | Command/Action                                                                               |
|----------------|----------------------------------------------------------------------------------------------|
| ll             | `ls -la` (List all files in long format)                                                     |
| la             | `ls -A` (List all files including hidden)                                                    |
| l              | `ls -CF` (List files in columns)                                                             |
| ..             | `cd ..` (Go up one directory)                                                                |
| ...            | `cd ../..` (Go up two directories)                                                           |
| grep           | `grep --color=auto` (Colorized grep output)                                                  |
| update         | `sudo nixos-rebuild switch --flake .#default` (Update system)                                |
| home-update    | `home-manager switch --flake .#default` (Update home configuration)                          |
| nixclean       | `sudo nix-collect-garbage -d` (Clean old generations)                                        |
| nixlist        | `sudo nix-env --list-generations --profile /nix/var/nix/profiles/system` (List generations)  |
| edithosts      | `sudo nvim /etc/nixos/hosts/configuration.nix` (Edit system config)                          |
| edithome       | `nvim ~/nixos-config/home-manager/home.nix` (Edit home config)                               |
| g              | `git`                                                                                        |
| ga             | `git add`                                                                                    |
| gc             | `git commit`                                                                                 |
| gco            | `git checkout`                                                                               |
| gp             | `git push`                                                                                   |
| gl             | `git pull`                                                                                   |
| gsb            | `git status -sb` (Compact git status)                                                        |


## Directory Structure

```
nixos-config/
├── flake.nix          # Main entry point
├── flake.lock         # Pinned dependencies
├── variables.nix      # Global variables
├── hosts/             # System configuration
│   ├── default.nix
│   ├── configuration.nix
│   └── machine-specific/
│       ├── laptop.nix
│       ├── desktop.nix
│       └── vm.nix
├── home-manager/      # User environment
│   ├── default.nix
│   ├── home.nix       # Home manager configuration
│   ├── programs/      # Program configurations
│   │   ├── default.nix
│   │   ├── sway/
│   │   ├── waybar/
│   │   ├── neovim/
│   │   └── ...
│   └── themes/        # Theme configurations
│       ├── default.nix
│       └── colors.nix
├── themes/            # Global theme definitions
│   └── gruvbox.nix    # Centralized color scheme
├── thorium-browser/   # External application flake
│   └── flake.nix
├── modules/           # Custom NixOS modules
│   ├── default.nix
│   └── system/
├── overlays/          # Package modifications
│   └── default.nix
└── pkgs/              # Custom packages
    └── default.nix
```

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests to improve this configuration.
