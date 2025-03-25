# NixOS Configuration with Flakes and Home Manager

<!-- Interactive Header: Badges & Table of Contents -->
[![NixOS](https://img.shields.io/badge/NixOS-config--enabled-brightgreen)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Flakes-enabled-blue)](https://nixos.wiki/wiki/Flakes)

**Table of Contents**
- [Overview](#overview)
- [Core Files](#core-files)
- [System Configuration](#system-configuration)
- [User Environment](#user-environment)
- [Keyboard Shortcuts and Aliases](#keyboard-shortcuts-and-aliases)
- [Directory Structure](#directory-structure)
- [Contributing](#contributing)

## Overview

This repository contains a modular NixOS configuration using flakes and Home Manager, designed to provide a reproducible and customizable system environment with a focus on consistency and organization.

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

## Installation and Usage

### Prerequisites

- A minimal NixOS installation (can be from a live USB)
- Internet connection
- Basic knowledge of command line usage

### Initial Setup on a Fresh NixOS Installation

1. **Install Git and enable flakes**:

   ```bash
   # Edit your temporary system configuration
   sudo nano /etc/nixos/configuration.nix
   ```

   Add these lines to enable flakes:
   ```nix
   { pkgs, ... }: {
     # Your existing config...
     
     nix.settings.experimental-features = [ "nix-command" "flakes" ];
     environment.systemPackages = with pkgs; [
       git
     ];
   }
   ```

   Apply the changes:
   ```bash
   sudo nixos-rebuild switch
   ```

2. **Clone this repository**:

   ```bash
   git clone https://github.com/manuja-me/nixos-config.git
   cd nixos-config
   ```

3. **Adjust configuration for your system**:

   - Edit `variables.nix` to set your username, hostname, and other personal settings
   - Review and modify `hosts/machine-specific/` files to match your hardware
   - Customize `home-manager/programs/` and `home-manager/themes/` to your preferences

4. **Build and apply the system configuration**:

   ```bash
   # Apply the full system configuration
   sudo nixos-rebuild switch --flake .#default
   ```

5. **Apply the Home Manager configuration**:

   ```bash
   # Apply user-level configurations
   home-manager switch --flake .#default
   ```

6. **Reboot to ensure all changes take effect**:

   ```bash
   sudo reboot
   ```

### Maintaining Your System

- **Update your system**:

  ```bash
  # Update flake inputs to latest versions
  nix flake update
  
  # Apply updates to system
  sudo nixos-rebuild switch --flake .#default
  
  # Apply updates to user environment
  home-manager switch --flake .#default
  ```

- **Roll back if needed**:

  ```bash
  # List generations
  sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
  
  # Roll back to previous generation
  sudo nixos-rebuild switch --rollback
  ```

### Customization Guide

1. **Add new system packages**:
   - Edit `hosts/configuration.nix` to add system-wide packages
   - Or add machine-specific packages in the relevant files under `hosts/machine-specific/`

2. **Add user programs**:
   - Edit `home-manager/programs/default.nix` for user applications
   - Create new files in `home-manager/programs/` for complex program configurations

3. **Change theme**:
   - Modify `themes/gruvbox.nix` to adjust color scheme

4. **Add custom packages**:
   - Place package definitions in `pkgs/`
   - Reference them in your configuration

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
