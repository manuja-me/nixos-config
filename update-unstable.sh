#!/usr/bin/env bash

# Script to update all flake inputs to the latest nixos-24.11 stable versions
# Usage: ./update-24.11.sh

# Set colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Updating all flake inputs to latest nixos-24.11 stable versions...${NC}"

# Update the main flake
echo -e "${GREEN}Updating main nixos-config flake to 24.11...${NC}"
cd "$(dirname "$0")" || exit 1
nix flake lock --update-input nixpkgs github:NixOS/nixpkgs/nixos-24.11
nix flake lock --update-input home-manager github:nix-community/home-manager/release-24.11

# Update thorium-browser flake if it exists
THORIUM_DIR="../thorium-browser"
if [ -d "$THORIUM_DIR" ]; then
  echo -e "${GREEN}Updating thorium-browser flake to 24.11...${NC}"
  cd "$THORIUM_DIR" || exit 1
  nix flake lock --update-input nixpkgs github:NixOS/nixpkgs/nixos-24.11
  cd - || exit 1
fi

echo -e "${GREEN}All flakes updated to latest 24.11 stable versions.${NC}"
echo -e "${YELLOW}Run 'sudo nixos-rebuild switch --flake .#default' to apply the updates.${NC}"
