#!/bin/bash
# Shell Configuration Library
# Handles Bash and Fish shell setup and switching
# Source this file: source "$(dirname "$0")/lib/shell.sh"

# Requires: lib/tui.sh to be sourced first

OMARCHY_FISH_REPO="https://github.com/omacom-io/omarchy-fish.git"
OMARCHY_FISH_DIR="$HOME/.local/share/omarchy/fish"
SHELL_PREF_FILE="$HOME/.config/omarchy/shell"

# =============================================================================
# Shell Preference Management
# =============================================================================

# Get current shell preference
shell_get_preference() {
    if [[ -f "$SHELL_PREF_FILE" ]]; then
        cat "$SHELL_PREF_FILE"
    else
        echo "bash"
    fi
}

# Set shell preference
shell_set_preference() {
    local shell="$1"
    mkdir -p "$(dirname "$SHELL_PREF_FILE")"
    echo "$shell" > "$SHELL_PREF_FILE"
    chmod 644 "$SHELL_PREF_FILE"

    # Also export for current session
    export OMARCHY_SHELL="$shell"
}

# =============================================================================
# Fish Shell Installation
# =============================================================================

# Install fish shell package
install_fish_package() {
    if command -v fish &>/dev/null; then
        tui_success "Fish shell already installed"
        return 0
    fi

    tui_info "Installing Fish shell..."
    if command -v yay &>/dev/null; then
        if tui_spin "Installing fish..." yay -S --noconfirm fish; then
            tui_success "Fish shell installed"
            return 0
        fi
    fi

    tui_error "Could not install fish. Please install manually: yay -S fish"
    return 1
}

# Clone or update omarchy-fish configuration
install_omarchy_fish() {
    if [[ -d "$OMARCHY_FISH_DIR" ]]; then
        tui_info "Updating omarchy-fish..."
        if (cd "$OMARCHY_FISH_DIR" && git pull --quiet); then
            tui_success "omarchy-fish updated"
        else
            tui_warning "Could not update omarchy-fish, using existing version"
        fi
    else
        tui_info "Cloning omarchy-fish..."
        mkdir -p "$(dirname "$OMARCHY_FISH_DIR")"
        if git clone --quiet --depth 1 "$OMARCHY_FISH_REPO" "$OMARCHY_FISH_DIR"; then
            tui_success "omarchy-fish cloned"
        else
            tui_error "Could not clone omarchy-fish"
            return 1
        fi
    fi

    # Run the omarchy-fish setup script
    local setup_script="$OMARCHY_FISH_DIR/bin/omarchy-setup-fish"
    if [[ -x "$setup_script" ]]; then
        tui_info "Running omarchy-fish setup..."
        if bash "$setup_script"; then
            tui_success "omarchy-fish configured"
        else
            tui_warning "omarchy-fish setup had issues, check manually"
        fi
    else
        tui_warning "omarchy-setup-fish script not found or not executable"
    fi
}

# Configure fish to source secrets
# Fish secrets parsing expects ~/.secrets format:
#   export KEY="value"
# - Must use double quotes around value
# - Handles values with spaces, but not embedded quotes
configure_fish_secrets() {
    local fish_config="$HOME/.config/fish/config.fish"

    # Create fish config directory if needed
    mkdir -p "$(dirname "$fish_config")"

    # Check if secrets sourcing already exists
    if [[ -f "$fish_config" ]] && grep -q "Source secrets from ~/.secrets" "$fish_config"; then
        tui_muted "Fish already configured to source secrets"
        return 0
    fi

    # Add secrets sourcing to fish config
    local secrets_block='
# Source secrets from ~/.secrets (bash format export statements)
if test -f ~/.secrets
    for line in (grep -E "^export " ~/.secrets)
        set -l kv (string replace "export " "" $line | string replace -r "=\"(.*)\"\\s*\$" "=\$1")
        set -l key (string split -m1 "=" $kv)[1]
        set -l val (string split -m1 "=" $kv)[2]
        set -gx $key $val
    end
end
'

    if [[ -f "$fish_config" ]]; then
        # Prepend to existing config
        local temp_file
        temp_file=$(mktemp)
        echo "$secrets_block" > "$temp_file"
        cat "$fish_config" >> "$temp_file"
        mv "$temp_file" "$fish_config"
    else
        # Create new config
        echo "$secrets_block" > "$fish_config"
        echo "" >> "$fish_config"
        echo "if status is-interactive" >> "$fish_config"
        echo "    # Commands to run in interactive sessions can go here" >> "$fish_config"
        echo "end" >> "$fish_config"
    fi

    tui_success "Fish configured to source secrets"
}

# Full fish shell installation
install_fish_shell() {
    tui_subheader "Fish Shell Setup"
    echo ""

    # Install fish package
    if ! install_fish_package; then
        return 1
    fi

    # Install omarchy-fish configuration
    install_omarchy_fish

    # Configure secrets
    configure_fish_secrets

    # Set preference
    shell_set_preference "fish"

    tui_success "Fish shell configured as default"
    tui_muted "Open a new terminal to use Fish"
}

# =============================================================================
# Bash Shell Configuration
# =============================================================================

# Ensure bash sources secrets
configure_bash_secrets() {
    local bashrc="$HOME/.bashrc"

    if [[ -f "$bashrc" ]] && grep -q '\[\[ -f ~/.secrets \]\] && source ~/.secrets' "$bashrc"; then
        tui_muted "Bash already configured to source secrets"
        return 0
    fi

    tui_muted "Secrets sourcing handled by updated .bashrc"
}

# Configure bash as primary shell (remove fish auto-exec)
install_bash_shell() {
    tui_subheader "Bash Shell Setup"
    echo ""

    # Set preference to bash
    shell_set_preference "bash"

    # Configure secrets
    configure_bash_secrets

    tui_success "Bash shell configured as default"
    tui_muted "Open a new terminal to use Bash"
}

# =============================================================================
# Shell Switching
# =============================================================================

# Switch to fish shell
switch_to_fish() {
    tui_header "Switching to Fish Shell"
    echo ""

    install_fish_shell
}

# Switch to bash shell
switch_to_bash() {
    tui_header "Switching to Bash Shell"
    echo ""

    install_bash_shell
}

# =============================================================================
# Interactive Selection
# =============================================================================

# Prompt user to select shell during installation
select_shell() {
    tui_subheader "Shell Configuration"
    echo ""
    tui_info "Choose your primary shell:"
    tui_muted "  Fish - Modern shell with auto-suggestions (recommended)"
    tui_muted "  Bash - Traditional shell, omarchy defaults included"
    echo ""

    local choice
    choice=$(tui_choose "Fish (recommended)" "Bash")

    case "$choice" in
        "Fish"*)
            install_fish_shell
            ;;
        "Bash")
            install_bash_shell
            ;;
        *)
            # Default to bash if no selection
            tui_muted "No selection made, defaulting to Bash"
            install_bash_shell
            ;;
    esac
}

# =============================================================================
# Verification
# =============================================================================

# Verify secrets are available in the current shell
shell_verify_secrets() {
    local shell_pref
    shell_pref=$(shell_get_preference)

    if [[ "$shell_pref" == "fish" ]]; then
        local fish_config="$HOME/.config/fish/config.fish"
        if [[ -f "$fish_config" ]] && grep -q "\.secrets" "$fish_config"; then
            return 0
        fi
        tui_warning "Fish config doesn't source ~/.secrets"
        return 1
    else
        local bashrc="$HOME/.bashrc"
        if [[ -f "$bashrc" ]] && grep -q '\.secrets' "$bashrc"; then
            return 0
        fi
        tui_warning ".bashrc doesn't source ~/.secrets"
        return 1
    fi
}
