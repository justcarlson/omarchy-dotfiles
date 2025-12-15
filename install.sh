#!/bin/bash
# Omarchy Dotfiles Installation Script
# A delightful setup experience for your Omarchy system

set -e  # Exit on any error

# =============================================================================
# Setup
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source libraries
source "$SCRIPT_DIR/lib/tui.sh"
source "$SCRIPT_DIR/lib/secrets.sh"
source "$SCRIPT_DIR/lib/packages.sh"

# Setup clean exit on Ctrl+C
tui_setup_trap

# =============================================================================
# Command Line Arguments
# =============================================================================
DRY_RUN=false
SKIP_PACKAGES=false
SKIP_SECRETS=false
DEBUG=false

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --check          Dry run - show what would be done without making changes"
    echo "  --skip-packages  Skip optional package installation"
    echo "  --skip-secrets   Skip API key configuration"
    echo "  --debug          Enable debug output for troubleshooting"
    echo "  -h, --help       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0              # Full interactive install"
    echo "  $0 --check      # Preview changes without applying"
    echo "  $0 --debug      # Run with debug output"
    echo "  $0 --skip-packages --skip-secrets  # Minimal install"
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --check)
                DRY_RUN=true
                shift
                ;;
            --skip-packages)
                SKIP_PACKAGES=true
                shift
                ;;
            --skip-secrets)
                SKIP_SECRETS=true
                shift
                ;;
            --debug)
                DEBUG=true
                export OMARCHY_DEBUG=1
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                tui_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
}

# =============================================================================
# Configuration
# =============================================================================

# Configs managed by stow (paths relative to ~/)
CONFIGS=(
    ".config/hypr"
    ".config/waybar"
    ".config/walker"
    ".config/ghostty"
    ".config/uwsm"
    ".config/opencode"
    ".config/cursor-flags.conf"
    ".config/starship.toml"
    ".config/Typora/themes/ia_typora.css"
    ".config/Typora/themes/ia_typora_night.css"
    ".bashrc"
    ".XCompose"
    ".local/share/warp-terminal"
)

# Build dependencies for hyprpm (Hy3 plugin)
HYPRPM_BUILD_DEPS=("meson" "cmake" "cpio")

# =============================================================================
# Core Functions
# =============================================================================

install_stow() {
    if command -v stow &>/dev/null; then
        tui_success "GNU Stow already installed"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        tui_info "[DRY RUN] Would install GNU Stow"
        return 0
    fi
    
    tui_info "Installing GNU Stow..."
    if command -v yay &>/dev/null; then
        if tui_spin "Installing stow..." yay -S --noconfirm stow; then
            tui_success "Stow installed"
            return 0
        fi
    fi
    
    tui_error "Could not install stow. Please install manually: yay -S stow"
    exit 1
}

backup_existing_configs() {
    local needs_backup=false
    local configs_to_backup=()
    
    for config in "${CONFIGS[@]}"; do
        if [[ -e "$HOME/$config" && ! -L "$HOME/$config" ]]; then
            needs_backup=true
            configs_to_backup+=("$config")
        fi
    done
    
    if [[ "$needs_backup" == "false" ]]; then
        tui_muted "No existing configs to backup"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        tui_info "[DRY RUN] Would backup ${#configs_to_backup[@]} configs:"
        for config in "${configs_to_backup[@]}"; do
            tui_muted "  $config"
        done
        return 0
    fi
    
    BACKUP_DIR="$HOME/omarchy-backup-$(date +%Y%m%d-%H%M%S)"
    tui_info "Backing up existing configs to: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    
    for config in "${configs_to_backup[@]}"; do
        local parent_dir
        parent_dir=$(dirname "$config")
        mkdir -p "$BACKUP_DIR/$parent_dir"
        mv "$HOME/$config" "$BACKUP_DIR/$config"
        tui_muted "Backed up: $config"
    done
    
    tui_success "Backup complete"
}

stow_configs() {
    # Check if already stowed (idempotent)
    local already_stowed=true
    for config in "${CONFIGS[@]}"; do
        if [[ ! -L "$HOME/$config" ]]; then
            already_stowed=false
            break
        fi
    done
    
    if [[ "$already_stowed" == "true" ]]; then
        tui_success "Symlinks already in place"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        tui_info "[DRY RUN] Would create symlinks via stow"
        # Show what would be linked
        local would_link=0
        for config in "${CONFIGS[@]}"; do
            if [[ ! -L "$HOME/$config" ]]; then
                tui_muted "  Would link: $config"
                would_link=$((would_link + 1))
            fi
        done
        tui_muted "  Total: $would_link symlinks"
        return 0
    fi
    
    tui_info "Creating symlinks..."
    
    # Capture stow output for better error reporting
    local stow_output
    if stow_output=$(stow omarchy-config 2>&1); then
        tui_success "Symlinks created"
        return 0
    else
        tui_error "Failed to create symlinks"
        tui_muted "$stow_output"
        
        # Attempt rollback if we have a backup
        if [[ -n "$BACKUP_DIR" && -d "$BACKUP_DIR" ]]; then
            tui_warning "Attempting rollback..."
            rollback_configs
        fi
        exit 1
    fi
}

# Rollback configs from backup directory
rollback_configs() {
    if [[ -z "$BACKUP_DIR" || ! -d "$BACKUP_DIR" ]]; then
        tui_error "No backup directory available for rollback"
        return 1
    fi
    
    # First, unstow any partial symlinks
    stow -D omarchy-config 2>/dev/null || true
    
    # Restore backed up configs
    local restored=0
    for config in "${CONFIGS[@]}"; do
        if [[ -e "$BACKUP_DIR/$config" ]]; then
            local parent_dir
            parent_dir=$(dirname "$HOME/$config")
            mkdir -p "$parent_dir"
            
            # Remove any broken symlink
            [[ -L "$HOME/$config" ]] && rm "$HOME/$config"
            
            mv "$BACKUP_DIR/$config" "$HOME/$config"
            tui_muted "Restored: $config"
            restored=$((restored + 1))
        fi
    done
    
    if [[ $restored -gt 0 ]]; then
        tui_success "Rollback complete: $restored configs restored"
        tui_muted "Backup preserved at: $BACKUP_DIR"
    else
        tui_warning "No configs to restore"
    fi
}

install_hy3() {
    tui_subheader "Hy3 Tiling Plugin"
    echo ""
    tui_info "Hy3 provides i3/sway-like manual tiling for Hyprland"
    tui_muted "Requires build dependencies and hyprpm setup"
    echo ""
    
    if ! tui_confirm "Install Hy3 plugin?"; then
        tui_muted "Skipping Hy3. Install later with:"
        tui_muted "  yay -S meson cmake cpio && hyprpm update"
        tui_muted "  hyprpm add https://github.com/outfoxxed/hy3 && hyprpm enable hy3"
        
        # Comment out hy3.conf if skipped
        local hy3_conf="$HOME/.config/hypr/hyprland.conf"
        if [[ -f "$hy3_conf" ]] && grep -q "^source = ~/.config/hypr/hy3.conf" "$hy3_conf"; then
            sed -i 's|^source = ~/.config/hypr/hy3.conf|# source = ~/.config/hypr/hy3.conf  # Uncomment after installing Hy3|' "$hy3_conf"
            tui_muted "Commented out hy3.conf (enable after installing)"
        fi
        return 0
    fi
    
    # Install build dependencies
    local missing_deps=()
    for dep in "${HYPRPM_BUILD_DEPS[@]}"; do
        if ! pacman -Qi "$dep" &>/dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        if tui_spin "Installing build dependencies..." yay -S --noconfirm "${missing_deps[@]}"; then
            tui_success "Build dependencies installed"
        else
            tui_error "Failed to install build dependencies"
            tui_muted "Try manually: yay -S ${missing_deps[*]}"
            return 1
        fi
    else
        tui_success "Build dependencies already installed"
    fi
    
    # Setup hyprpm
    tui_spin "Updating hyprpm headers..." hyprpm update || true
    
    # Install hy3
    if hyprpm list 2>/dev/null | grep -q "hy3"; then
        tui_success "Hy3 already installed"
    else
        if echo "y" | hyprpm add https://github.com/outfoxxed/hy3 &>/dev/null; then
            tui_success "Hy3 plugin added"
        else
            tui_error "Failed to add Hy3 plugin"
            tui_muted "Try manually: hyprpm add https://github.com/outfoxxed/hy3"
            return 1
        fi
    fi
    
    # Enable hy3
    hyprpm enable hy3 &>/dev/null || true
    tui_success "Hy3 enabled - restart Hyprland to activate"
}

install_cli_agents() {
    tui_subheader "CLI Coding Agents"
    echo ""
    tui_info "OpenCode (primary) - Open source AI coding agent"
    tui_info "Claude Code (fallback) - Anthropic's agentic coding tool"
    echo ""
    
    # Install OpenCode (primary)
    if command -v opencode &>/dev/null; then
        tui_success "OpenCode already installed"
    elif tui_confirm "Install OpenCode (primary CLI agent)?"; then
        if tui_spin "Installing OpenCode..." bash -c 'curl -fsSL https://opencode.ai/install | bash'; then
            tui_success "OpenCode installed"
            tui_muted "Run 'opencode' to start"
        else
            tui_error "Failed to install OpenCode"
            tui_muted "Try manually: curl -fsSL https://opencode.ai/install | bash"
        fi
    else
        tui_muted "Skipping OpenCode. Install later: curl -fsSL https://opencode.ai/install | bash"
    fi
    
    echo ""
    
    # Install Claude Code (fallback)
    if command -v claude &>/dev/null; then
        tui_success "Claude Code already installed"
    elif tui_confirm "Install Claude Code (fallback CLI agent)?"; then
        # Ensure npm is available
        if ! command -v npm &>/dev/null; then
            tui_info "Installing Node.js..."
            if ! tui_spin "Installing nodejs..." yay -S --noconfirm nodejs npm; then
                tui_error "Failed to install Node.js"
                return 1
            fi
        fi
        
        if tui_spin "Installing Claude Code..." npm install -g @anthropic-ai/claude-code; then
            tui_success "Claude Code installed"
            tui_muted "Run 'claude' to start and authenticate"
            
            # Status line setup
            echo ""
            if tui_confirm "Configure custom status line (git info + context %)?" && \
               [[ -x "$HOME/.local/bin/setup-claude-code-statusline.sh" ]]; then
                bash "$HOME/.local/bin/setup-claude-code-statusline.sh"
            fi
        else
            tui_error "Failed to install Claude Code"
            tui_muted "Try manually: npm install -g @anthropic-ai/claude-code"
        fi
    else
        tui_muted "Skipping Claude Code. Install later: npm install -g @anthropic-ai/claude-code"
    fi
}

install_optional_packages() {
    tui_subheader "Optional Packages"
    echo ""
    
    # Check what's available
    local available_count=0
    for entry in "${PACKAGE_REGISTRY[@]}"; do
        local name
        name=$(pkg_get_field "$entry" "name")
        if ! pkg_is_installed "$name"; then
            available_count=$((available_count + 1))
        fi
    done
    
    if [[ $available_count -eq 0 ]]; then
        tui_success "All optional packages already installed!"
        return 0
    fi
    
    tui_info "$available_count packages available to install:"
    pkg_display_available
    echo ""
    
    local choice
    choice=$(tui_choose "Install all" "Select packages" "Skip")
    
    # Handle empty choice explicitly
    if [[ -z "$choice" ]]; then
        tui_warning "No selection made (possible gum/TTY issue). Defaulting to Skip."
        tui_muted "Skipping. Install later with: yay -S <package>"
        # Still update autostart config
        tui_info "Updating autostart configuration..."
        pkg_write_autostart_file
        tui_success "autostart-apps.conf updated"
        return 0
    fi
    
    case "$choice" in
        "Install all")
            local all_packages=()
            for entry in "${PACKAGE_REGISTRY[@]}"; do
                local name
                name=$(pkg_get_field "$entry" "name")
                if ! pkg_is_installed "$name"; then
                    all_packages+=("$name")
                fi
            done
            pkg_install_many "${all_packages[@]}"
            ;;
        "Select packages")
            pkg_select_interactive
            ;;
        "Skip"|*)
            tui_muted "Skipping. Install later with: yay -S <package>"
            ;;
    esac
    
    # Regenerate autostart-apps.conf based on installed packages
    tui_info "Updating autostart configuration..."
    pkg_write_autostart_file
    tui_success "autostart-apps.conf updated"
}

configure_secrets() {
    tui_subheader "API Keys & Secrets"
    echo ""
    tui_info "Store API keys securely in ~/.secrets (never committed to git)"
    echo ""
    
    if ! tui_confirm "Configure API keys?"; then
        tui_muted "Skipping. Add keys later to ~/.secrets"
        return 0
    fi
    
    secrets_init
    secrets_collect_mcp
    
    # Configure MCP for tools that need it
    local exa_key ref_key
    exa_key=$(secrets_get "EXA_API_KEY")
    ref_key=$(secrets_get "REF_API_KEY")
    
    if [[ -n "$exa_key" || -n "$ref_key" ]]; then
        configure_mcp_servers "$exa_key" "$ref_key"
    fi
    
    echo ""
    secrets_verify_permissions
    secrets_verify_bashrc
}

configure_mcp_servers() {
    local exa_key="$1"
    local ref_key="$2"
    
    tui_info "Configuring MCP servers..."
    
    # Build MCP config JSON for Cursor (OpenCode uses ~/.config/opencode/opencode.jsonc)
    local mcp_config='{"mcpServers":{'
    local first=true
    
    if [[ -n "$exa_key" ]]; then
        mcp_config+='"exa":{"type":"http","url":"https://mcp.exa.ai/mcp?exaApiKey='"$exa_key"'","headers":{}}'
        first=false
    fi
    
    if [[ -n "$ref_key" ]]; then
        [[ "$first" == "false" ]] && mcp_config+=','
        mcp_config+='"Ref":{"type":"http","url":"https://api.ref.tools/mcp?apiKey='"$ref_key"'","headers":{}}'
    fi
    
    mcp_config+='}}'
    
    # Write config for Cursor
    mkdir -p "$HOME/.cursor"
    echo "$mcp_config" > "$HOME/.cursor/mcp.json"
    chmod 600 "$HOME/.cursor/mcp.json"
    
    tui_success "MCP config created for Cursor"
    tui_muted "OpenCode MCP config managed via ~/.config/opencode/opencode.jsonc"
    
    # Configure Claude Code if installed
    if command -v claude &>/dev/null; then
        if [[ -n "$exa_key" ]]; then
            claude mcp add exa --transport http "https://mcp.exa.ai/mcp?exaApiKey=$exa_key" --scope user 2>/dev/null && \
                tui_muted "Added exa MCP to Claude Code"
        fi
        if [[ -n "$ref_key" ]]; then
            claude mcp add Ref --transport http "https://api.ref.tools/mcp?apiKey=$ref_key" --scope user 2>/dev/null && \
                tui_muted "Added Ref MCP to Claude Code"
        fi
    fi
}

show_summary() {
    tui_header "Setup Complete!"
    
    echo "Your Omarchy dotfiles are now installed."
    echo ""
    echo "Configured:"
    tui_muted "Hyprland (window manager)"
    tui_muted "Waybar (status bar)"
    tui_muted "Walker (launcher)"
    tui_muted "Ghostty (terminal)"
    tui_muted "Starship (prompt)"
    tui_muted ".bashrc and .XCompose"
    echo ""
    
    if [[ -n "$BACKUP_DIR" ]]; then
        tui_info "Original configs backed up to:"
        tui_muted "$BACKUP_DIR"
        echo ""
    fi
    
    tui_warning "Restart Hyprland or reboot for all changes to take effect"
}

# =============================================================================
# Main Installation Flow
# =============================================================================

main() {
    if [[ "$DRY_RUN" == "true" ]]; then
        tui_header "Omarchy Dotfiles (DRY RUN)"
        tui_warning "No changes will be made"
        echo ""
    else
        tui_header "Omarchy Dotfiles"
    fi
    
    # Ensure gum is available for best experience
    tui_ensure_gum
    
    # Step 1: Prerequisites
    tui_step 1 6 "Checking prerequisites"
    install_stow
    echo ""
    
    # Step 2: Backup & Stow
    tui_step 2 6 "Installing configs"
    backup_existing_configs
    stow_configs
    echo ""
    
    # Step 3: Hy3 Plugin
    tui_step 3 6 "Hyprland plugins"
    if [[ "$DRY_RUN" == "true" ]]; then
        tui_info "[DRY RUN] Would prompt for Hy3 installation"
    else
        install_hy3
    fi
    echo ""
    
    # Step 4: CLI Agents (OpenCode + Claude Code)
    tui_step 4 6 "CLI coding agents"
    if [[ "$DRY_RUN" == "true" ]]; then
        tui_info "[DRY RUN] Would prompt for CLI agent installation (OpenCode, Claude Code)"
    else
        install_cli_agents
    fi
    echo ""
    
    # Step 5: Optional Packages
    tui_step 5 6 "Optional packages"
    if [[ "$SKIP_PACKAGES" == "true" ]]; then
        tui_muted "Skipped (--skip-packages)"
    elif [[ "$DRY_RUN" == "true" ]]; then
        tui_info "[DRY RUN] Would prompt for optional packages"
        pkg_display_available
    else
        install_optional_packages
    fi
    echo ""
    
    # Step 6: Secrets & MCP
    tui_step 6 6 "API keys & secrets"
    if [[ "$SKIP_SECRETS" == "true" ]]; then
        tui_muted "Skipped (--skip-secrets)"
    elif [[ "$DRY_RUN" == "true" ]]; then
        tui_info "[DRY RUN] Would prompt for API key configuration"
    else
        configure_secrets
    fi
    echo ""
    
    # Done!
    if [[ "$DRY_RUN" == "true" ]]; then
        tui_header "Dry Run Complete"
        tui_info "Run without --check to apply changes"
    else
        show_summary
    fi
}

# Parse arguments and run
parse_args "$@"
main
