#!/bin/bash
# Check for user-installed packages not part of Omarchy base installation
# Compares your explicitly installed packages against Omarchy's official package lists

set -e

echo "Fetching Omarchy package lists..."

# Fetch Omarchy package lists from GitHub
OMARCHY_BASE=$(curl -s https://raw.githubusercontent.com/basecamp/omarchy/master/install/omarchy-base.packages)
OMARCHY_OTHER=$(curl -s https://raw.githubusercontent.com/basecamp/omarchy/master/install/omarchy-other.packages)

# Combine into one list, removing comments and empty lines
OMARCHY_ALL=$(echo -e "$OMARCHY_BASE\n$OMARCHY_OTHER" | grep -v '^#' | grep -v '^$' | sort -u)

# Packages already in your install.sh OPTIONAL_PACKAGES
DOTFILES_PACKAGES="visual-studio-code-bin google-chrome-beta tailscale solaar python-pipx tree bun-bin claude-code wev"

# Get explicitly installed packages
INSTALLED=$(pacman -Qeq | sort)

# Find packages not in Omarchy or your dotfiles
USER_PACKAGES=$(comm -23 <(echo "$INSTALLED") <(echo -e "$OMARCHY_ALL\n$DOTFILES_PACKAGES" | tr ' ' '\n' | sort -u))

if [ -z "$USER_PACKAGES" ]; then
    echo ""
    echo "No additional packages found - your system matches Omarchy base installation."
else
    echo ""
    echo "Packages installed by you (not in Omarchy base):"
    echo "================================================"
    echo "$USER_PACKAGES"
    echo ""
    echo "Total: $(echo "$USER_PACKAGES" | wc -l) package(s)"
fi
