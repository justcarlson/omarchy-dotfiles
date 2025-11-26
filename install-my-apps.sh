#!/bin/bash

# install-my-apps.sh
# Auto-install Justin's additional apps via yay
# Run this after setting up a fresh Omarchy system

set -e  # Exit on error

echo "Installing Justin's apps..."

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Just the essentials that don't come with Omarchy
PACKAGES=(
    google-chrome-beta
    stow
    ripgrep
    solaar
)

echo -e "\n${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  Installing Additional Apps${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}\n"

for package in "${PACKAGES[@]}"; do
    echo -e "${GREEN}→ Installing $package${NC}"
    yay -S --noconfirm "$package"
done

echo -e "\n${GREEN}Installation complete!${NC}\n"
