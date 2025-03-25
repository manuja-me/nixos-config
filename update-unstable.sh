#!/usr/bin/env bash

# Script to update all flake inputs to the latest nixos-unstable versions
# Usage: ./update-unstable.sh

# Set colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Updating all flake inputs to latest nixos-unstable versions...${NC}"

# Update the main flake
echo -e "${GREEN}Updating main nixos-config flake...${NC}"
cd "$(dirname "$0")" || exit 1
nix flake update

# Update thorium-browser flake if it exists
THORIUM_DIR="../thorium-browser"
if [ -d "$THORIUM_DIR" ]; then
  echo -e "${GREEN}Updating thorium-browser flake...${NC}"
  cd "$THORIUM_DIR" || exit 1
  nix flake update
  cd - || exit 1
fi

echo -e "${GREEN}All flakes updated to latest unstable versions.${NC}"
echo -e "${YELLOW}Run 'sudo nixos-rebuild switch --flake .#default' to apply the updates.${NC}"
