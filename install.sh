#!/bin/bash

# Omarchy Dotfiles Installation Script
# This script installs GNU Stow (if needed), backs up existing configs, and stows your Omarchy configuration

set -e  # Exit on any error

echo "======================================"
echo "  Omarchy Dotfiles Installation"
echo "======================================"
echo ""

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo "📦 GNU Stow not found. Installing..."
    if command -v yay &> /dev/null; then
        yay -S --noconfirm stow
        echo "✅ Stow installed successfully"
    else
        echo "❌ Error: yay package manager not found"
        echo "Please install stow manually: yay -S stow"
        exit 1
    fi
else
    echo "✅ GNU Stow is already installed"
fi

echo ""

# Build dependencies required for hyprpm (Hyprland Plugin Manager)
# These are needed to compile plugins like Hy3
HYPRPM_BUILD_DEPS=(
    "meson"
    "cmake"
    "cpio"
)

# Packages not pre-installed on Omarchy but referenced in configs
# Format: "package|category|description"
# Note: Cursor is installed via AppImage, not AUR - see README-apps.md
OPTIONAL_PACKAGES=(
    "google-chrome-beta|Browser|Default browser (BROWSER)"
    "tailscale|Networking|Mesh VPN"
    "solaar|Utilities|Logitech device manager"
    "tree|Utilities|Directory tree viewer"
    "bun-bin|Development|JavaScript runtime"
    "wev|Utilities|Wayland event viewer"
    "wget|Utilities|Network file downloader"
)

# Track skipped apps for autostart cleanup
SKIPPED_APPS=()

# Map package names to autostart entry patterns
declare -A AUTOSTART_MAP=(
    ["google-chrome-beta"]="exec-once = uwsm-app -- google-chrome-beta"
    ["pygpt-net"]="exec-once = uwsm-app -- pygpt"
)

# Map package names to post-install commands
declare -A POST_INSTALL_MAP=()

# Display available packages
display_packages() {
    local i=1
    for entry in "${OPTIONAL_PACKAGES[@]}"; do
        IFS='|' read -r pkg category desc <<< "$entry"
        printf "  %d. %-24s %s\n" "$i" "$pkg" "- $desc"
        ((i++))
    done
}

# Install packages with progress reporting
install_packages() {
    local -a packages=("$@")
    local total=${#packages[@]}
    local current=0
    local -a failed=()
    local -a skipped=()

    echo ""
    for pkg in "${packages[@]}"; do
        ((++current))
        printf "[%d/%d] Installing %s... " "$current" "$total" "$pkg"
        
        # Check if package is already installed
        if pacman -Qi "$pkg" &>/dev/null; then
            echo "✅ (already installed)"
            skipped+=("$pkg")
            continue
        fi
        
        if yay -S --noconfirm "$pkg" &>/dev/null; then
            echo "✅"
            # Run post-install command if defined
            if [ -n "${POST_INSTALL_MAP[$pkg]}" ]; then
                eval "${POST_INSTALL_MAP[$pkg]}" 2>/dev/null
            fi
        else
            echo "❌"
            failed+=("$pkg")
        fi
    done

    if [ ${#skipped[@]} -gt 0 ]; then
        echo ""
        echo "ℹ️  Some packages were already installed:"
        for pkg in "${skipped[@]}"; do
            echo "   $pkg"
        done
    fi

    if [ ${#failed[@]} -gt 0 ]; then
        echo ""
        echo "⚠️  Some packages failed to install:"
        for pkg in "${failed[@]}"; do
            echo "   yay -S $pkg"
        done
    fi
}

# Interactive package selection
select_packages() {
    local -a selected=()
    echo ""
    echo "Enter package numbers separated by spaces (e.g., '1 3')"
    echo "Or press Enter to install all:"
    read -r selection

    if [ -z "$selection" ]; then
        # Return all packages
        for entry in "${OPTIONAL_PACKAGES[@]}"; do
            IFS='|' read -r pkg _ _ <<< "$entry"
            selected+=("$pkg")
        done
    else
        for num in $selection; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#OPTIONAL_PACKAGES[@]}" ]; then
                local entry="${OPTIONAL_PACKAGES[$((num-1))]}"
                IFS='|' read -r pkg _ _ <<< "$entry"
                selected+=("$pkg")
            fi
        done
    fi
    echo "${selected[@]}"
}

# Comment out autostart entries for skipped apps
cleanup_autostart() {
    local autostart_file="$HOME/.config/hypr/autostart.conf"

    if [ ! -f "$autostart_file" ]; then
        return
    fi

    local modified=false
    for app in "${SKIPPED_APPS[@]}"; do
        local pattern="${AUTOSTART_MAP[$app]}"
        if [ -n "$pattern" ] && grep -q "^${pattern}$" "$autostart_file" 2>/dev/null; then
            # Comment out the line
            sed -i "s|^${pattern}$|# ${pattern}  # Commented: not installed|" "$autostart_file"
            echo "  ✓ Commented out autostart for: $app"
            modified=true
        fi
    done

    if [ "$modified" = true ]; then
        echo ""
    fi
}

# Define configs that will be managed
CONFIGS=(
    ".config/hypr"
    ".config/waybar"
    ".config/walker"
    ".config/ghostty"
    ".config/uwsm"
    ".config/starship.toml"
    ".bashrc"
    ".XCompose"
    ".local/share/warp-terminal"
)

# Check if any configs exist and need backing up
BACKUP_NEEDED=false
for config in "${CONFIGS[@]}"; do
    if [ -e "$HOME/$config" ] && [ ! -L "$HOME/$config" ]; then
        BACKUP_NEEDED=true
        break
    fi
done

# Backup existing configs if needed
if [ "$BACKUP_NEEDED" = true ]; then
    BACKUP_DIR="$HOME/omarchy-backup-$(date +%Y%m%d-%H%M%S)"
    echo "📦 Backing up existing configs to: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    
    for config in "${CONFIGS[@]}"; do
        if [ -e "$HOME/$config" ] && [ ! -L "$HOME/$config" ]; then
            # Create parent directory structure in backup
            parent_dir=$(dirname "$config")
            mkdir -p "$BACKUP_DIR/$parent_dir"
            
            # Move the file/directory to backup
            mv "$HOME/$config" "$BACKUP_DIR/$config"
            echo "  ✓ Backed up: $config"
        fi
    done
    
    echo ""
    echo "✅ Backup complete: $BACKUP_DIR"
    echo ""
fi

echo "🔗 Creating symlinks for Omarchy configs..."
echo ""

# Stow the configuration
if stow omarchy-config; then
    echo ""
    echo "======================================"
    echo "  ✅ Installation Complete!"
    echo "======================================"
    echo ""
    echo "Your Omarchy dotfiles have been installed."
    echo ""
    echo "Configured:"
    echo "  • Hyprland (window manager)"
    echo "  • Waybar (top bar)"
    echo "  • Walker (launcher)"
    echo "  • Ghostty (terminal)"
    echo "  • Warp terminal themes (Catppuccin Mocha)"
    echo "  • uwsm (session manager)"
    echo "  • Starship (shell prompt)"
    echo "  • .bashrc and .XCompose"
    echo ""
    if [ "$BACKUP_NEEDED" = true ]; then
        echo "📦 Your original configs were backed up to:"
        echo "   $BACKUP_DIR"
        echo ""
    fi
    echo "⚠️  You may need to restart Hyprland or reboot for all changes to take effect."
    echo ""

    # Install Hy3 Hyprland Plugin (i3/sway-like tiling)
    echo "--------------------------------------"
    echo "  Installing Hy3 Tiling Plugin"
    echo "--------------------------------------"
    echo ""
    echo "Hy3 provides i3/sway-like manual tiling for Hyprland."
    echo "This requires build dependencies and hyprpm setup."
    echo ""
    read -p "Install Hy3 plugin? [Y/n]: " -n 1 -r hy3_choice
    echo ""

    if [[ ! "${hy3_choice,,}" == "n" ]]; then
        echo ""
        echo "📦 Installing hyprpm build dependencies..."
        
        # Install build deps
        missing_deps=()
        for dep in "${HYPRPM_BUILD_DEPS[@]}"; do
            if ! pacman -Qi "$dep" &>/dev/null; then
                missing_deps+=("$dep")
            fi
        done

        if [ ${#missing_deps[@]} -gt 0 ]; then
            echo "   Installing: ${missing_deps[*]}"
            if yay -S --noconfirm "${missing_deps[@]}" &>/dev/null; then
                echo "✅ Build dependencies installed"
            else
                echo "❌ Failed to install build dependencies"
                echo "   Try manually: yay -S ${missing_deps[*]}"
            fi
        else
            echo "✅ Build dependencies already installed"
        fi

        echo ""
        echo "🔧 Setting up hyprpm (this may take a minute)..."
        
        if hyprpm update 2>&1 | grep -v "^$"; then
            echo "✅ hyprpm headers updated"
        else
            echo "⚠️  hyprpm update had issues (may be OK if already configured)"
        fi

        echo ""
        echo "📦 Installing Hy3 plugin..."
        
        # Check if hy3 is already added
        if hyprpm list 2>/dev/null | grep -q "hy3"; then
            echo "✅ Hy3 already installed"
        else
            # Add hy3 repo (auto-accept with yes)
            if echo "y" | hyprpm add https://github.com/outfoxxed/hy3 2>&1 | grep -v "^$"; then
                echo "✅ Hy3 plugin added"
            else
                echo "❌ Failed to add Hy3 plugin"
                echo "   Try manually: hyprpm add https://github.com/outfoxxed/hy3"
            fi
        fi

        # Enable hy3
        if hyprpm enable hy3 2>&1 | grep -v "^$"; then
            echo "✅ Hy3 enabled"
        else
            echo "⚠️  Hy3 enable had issues"
        fi

        echo ""
        echo "✅ Hy3 setup complete!"
        echo "   Restart Hyprland for changes to take effect."
        echo ""
    else
        echo "Skipping Hy3 installation."
        echo "You can install later with:"
        echo "   yay -S meson cmake cpio"
        echo "   hyprpm update"
        echo "   hyprpm add https://github.com/outfoxxed/hy3"
        echo "   hyprpm enable hy3"
        echo ""
        
        # Comment out hy3.conf sourcing if user skips
        HY3_CONF="$HOME/.config/hypr/hyprland.conf"
        if [ -f "$HY3_CONF" ] && grep -q "^source = ~/.config/hypr/hy3.conf" "$HY3_CONF"; then
            sed -i 's|^source = ~/.config/hypr/hy3.conf|# source = ~/.config/hypr/hy3.conf  # Uncomment after installing Hy3|' "$HY3_CONF"
            echo "ℹ️  Commented out hy3.conf in hyprland.conf (enable after installing Hy3)"
        fi
    fi

    echo ""

    # Install Factory CLI
    echo "--------------------------------------"
    echo "  Installing Factory CLI"
    echo "--------------------------------------"
    echo ""
    if curl -fsSL https://app.factory.ai/cli | sh; then
        echo "✅ Factory CLI installed successfully"
    else
        echo "⚠️  Factory CLI installation failed"
        echo "   Try manually: curl -fsSL https://app.factory.ai/cli | sh"
    fi
    echo ""

    # Prompt for optional app installation
    echo "--------------------------------------"
    echo "  Optional: Install Additional Apps"
    echo "--------------------------------------"
    echo ""
    echo "Your configs reference ${#OPTIONAL_PACKAGES[@]} packages not pre-installed on Omarchy:"
    echo ""
    display_packages
    echo ""
    read -p "Install apps? [Y]es all / [n]o / [s]elect: " -n 1 -r choice
    echo ""

    case "${choice,,}" in
        n)
            echo ""
            echo "Skipping app installation."
            echo "You can install them later with: yay -S <package>"
            # Track all skipped packages that have autostart entries
            for entry in "${OPTIONAL_PACKAGES[@]}"; do
                IFS='|' read -r pkg _ _ <<< "$entry"
                if [ -n "${AUTOSTART_MAP[$pkg]}" ]; then
                    SKIPPED_APPS+=("$pkg")
                fi
            done
            ;;
        s)
            selected=($(select_packages))
            if [ ${#selected[@]} -gt 0 ]; then
                install_packages "${selected[@]}"
                echo ""
                echo "✅ App installation complete!"
            else
                echo "No packages selected."
            fi
            # Track skipped packages that have autostart entries
            for entry in "${OPTIONAL_PACKAGES[@]}"; do
                IFS='|' read -r pkg _ _ <<< "$entry"
                if [ -n "${AUTOSTART_MAP[$pkg]}" ]; then
                    local is_selected=false
                    for sel in "${selected[@]}"; do
                        if [ "$sel" == "$pkg" ]; then
                            is_selected=true
                            break
                        fi
                    done
                    if [ "$is_selected" = false ]; then
                        SKIPPED_APPS+=("$pkg")
                    fi
                fi
            done
            ;;
        *)
            # Default: install all
            all_packages=()
            for entry in "${OPTIONAL_PACKAGES[@]}"; do
                IFS='|' read -r pkg _ _ <<< "$entry"
                all_packages+=("$pkg")
            done
            install_packages "${all_packages[@]}"
            echo ""
            echo "✅ App installation complete!"
            ;;
    esac

    # Prompt for pipx-based apps
    echo ""
    echo "--------------------------------------"
    echo "  Optional: Install PyGPT via pipx"
    echo "--------------------------------------"
    echo ""

    # Auto-install pipx if not available
    if ! command -v pipx &>/dev/null; then
        echo "📦 pipx not found. Installing..."
        if yay -S --noconfirm python-pipx &>/dev/null; then
            echo "✅ pipx installed successfully"
            # Ensure pipx path is available in current session
            export PATH="$HOME/.local/bin:$PATH"
            # Persist PATH in shell configs
            pipx ensurepath --force &>/dev/null
        else
            echo "❌ Failed to install pipx"
            echo "   Install manually with: yay -S python-pipx"
            echo "   Then run: pipx install pygpt-net"
        fi
    fi

    if command -v pipx &>/dev/null; then
        read -p "Install PyGPT AI assistant? [Y/n]: " -n 1 -r pygpt_choice
        echo ""

        if [[ ! "${pygpt_choice,,}" == "n" ]]; then
            echo "Installing PyGPT via pipx..."
            if pipx install pygpt-net; then
                echo "✅ PyGPT installed successfully"
                echo ""
                echo "Run with: pygpt"
            else
                echo "❌ PyGPT installation failed"
                echo "   Try manually: pipx install pygpt-net"
            fi
        else
            echo "Skipping PyGPT. Install later with: pipx install pygpt-net"
            SKIPPED_APPS+=("pygpt-net")
        fi
    fi

    # Clean up autostart entries for skipped apps
    if [ ${#SKIPPED_APPS[@]} -gt 0 ]; then
        echo ""
        echo "🧹 Cleaning up autostart for skipped apps..."
        cleanup_autostart
    fi

    # Configure MCP servers for AI tools
    echo ""
    echo "--------------------------------------"
    echo "  Optional: Configure MCP Servers"
    echo "--------------------------------------"
    echo ""
    echo "MCP servers provide AI tools with web search and documentation capabilities."
    echo "These configs are stored locally (not in git) to protect your API keys."
    echo ""

    read -p "Configure MCP servers for Factory CLI and Cursor? [Y/n]: " -n 1 -r mcp_choice
    echo ""

    if [[ ! "${mcp_choice,,}" == "n" ]]; then
        read -p "Exa API key (get one at https://exa.ai): " exa_key
        read -p "Ref API key (get one at https://ref.tools): " ref_key

        if [ -n "$exa_key" ] || [ -n "$ref_key" ]; then
            # Build MCP config JSON
            MCP_CONFIG='{"mcpServers":{'
            first=true

            if [ -n "$exa_key" ]; then
                MCP_CONFIG+='"exa":{"type":"http","url":"https://mcp.exa.ai/mcp?exaApiKey='"$exa_key"'","headers":{}}'
                first=false
            fi

            if [ -n "$ref_key" ]; then
                [ "$first" = false ] && MCP_CONFIG+=','
                MCP_CONFIG+='"Ref":{"type":"http","url":"https://api.ref.tools/mcp?apiKey='"$ref_key"'","headers":{}}'
            fi

            MCP_CONFIG+='}}'

            # Create directories and write configs
            mkdir -p "$HOME/.factory" "$HOME/.cursor"
            echo "$MCP_CONFIG" > "$HOME/.factory/mcp.json"
            echo "$MCP_CONFIG" > "$HOME/.cursor/mcp.json"
            chmod 600 "$HOME/.factory/mcp.json" "$HOME/.cursor/mcp.json"

            echo "✅ MCP configs created:"
            echo "   ~/.factory/mcp.json"
            echo "   ~/.cursor/mcp.json"
        else
            echo "No API keys provided. Skipping MCP configuration."
        fi
    else
        echo "Skipping MCP configuration."
    fi

    echo ""
else
    echo ""
    echo "❌ Installation failed"
    echo ""
    echo "Please check the error messages above."
    echo ""
    if [ "$BACKUP_NEEDED" = true ]; then
        echo "Your original configs are backed up in: $BACKUP_DIR"
        echo ""
    fi
    exit 1
fi
