#!/bin/bash
# Secrets Management Library
# Handles ~/.secrets file creation and management
# Source this file: source "$(dirname "$0")/lib/secrets.sh"

# Requires: lib/tui.sh to be sourced first

SECRETS_FILE="$HOME/.secrets"

# =============================================================================
# Core Functions
# =============================================================================

# Check if secrets file exists
secrets_exists() {
    [[ -f "$SECRETS_FILE" ]]
}

# Initialize secrets file with proper permissions
secrets_init() {
    if ! secrets_exists; then
        touch "$SECRETS_FILE"
        chmod 600 "$SECRETS_FILE"
        cat > "$SECRETS_FILE" << 'EOF'
# Secrets file - API keys, tokens, credentials
# This file is sourced by .bashrc and should NEVER be committed to git
# Permissions should be 600 (owner read/write only)

# =============================================================================
# API Keys
# =============================================================================
# export TAVILY_API_KEY=""
# export REF_API_KEY=""

# =============================================================================
# Auth Tokens
# =============================================================================
# export GITHUB_TOKEN=""
# export ANTHROPIC_API_KEY=""

# =============================================================================
# Other Secrets
# =============================================================================

EOF
        tui_success "Created $SECRETS_FILE"
    fi
}

# Get a secret value (returns empty if not set)
secrets_get() {
    local key="$1"
    if secrets_exists; then
        grep "^export ${key}=" "$SECRETS_FILE" 2>/dev/null | sed "s/^export ${key}=\"\(.*\)\"$/\1/"
    fi
}

# Set a secret value (adds or updates)
secrets_set() {
    local key="$1"
    local value="$2"
    
    secrets_init  # Ensure file exists
    
    # Remove existing entry if present
    if grep -q "^export ${key}=" "$SECRETS_FILE" 2>/dev/null; then
        # Update existing
        sed -i "s|^export ${key}=.*|export ${key}=\"${value}\"|" "$SECRETS_FILE"
    elif grep -q "^# export ${key}=" "$SECRETS_FILE" 2>/dev/null; then
        # Uncomment and set
        sed -i "s|^# export ${key}=.*|export ${key}=\"${value}\"|" "$SECRETS_FILE"
    else
        # Append new
        echo "export ${key}=\"${value}\"" >> "$SECRETS_FILE"
    fi
    
    chmod 600 "$SECRETS_FILE"
}

# Check if a secret is set (non-empty)
secrets_has() {
    local key="$1"
    local value
    value=$(secrets_get "$key")
    [[ -n "$value" ]]
}

# =============================================================================
# Interactive Collection
# =============================================================================

# Prompt for a single secret
# Usage: secrets_prompt "TAVILY_API_KEY" "Tavily API key" "Get one at https://tavily.com"
secrets_prompt() {
    local key="$1"
    local label="$2"
    local hint="${3:-}"
    
    local current
    current=$(secrets_get "$key")
    
    if [[ -n "$current" ]]; then
        local masked="${current:0:4}...${current: -4}"
        tui_info "$label already set ($masked)"
        if ! tui_confirm "Update $label?" "false"; then
            return 0
        fi
    fi
    
    if [[ -n "$hint" ]]; then
        tui_muted "$hint"
    fi
    
    local value
    value=$(tui_secret "$label" "paste key here")
    
    if [[ -n "$value" ]]; then
        secrets_set "$key" "$value"
        tui_success "$label saved"
        return 0
    else
        tui_muted "Skipped (no value entered)"
        return 1
    fi
}

# Collect all MCP-related secrets
secrets_collect_mcp() {
    tui_subheader "MCP Server API Keys"
    echo ""
    tui_info "MCP servers provide AI tools with web search and documentation capabilities."
    tui_muted "Keys are stored in ~/.secrets (never committed to git)"
    echo ""
    
    secrets_prompt "TAVILY_API_KEY" "Tavily API key" "Get one at https://tavily.com"
    secrets_prompt "REF_API_KEY" "Ref API key" "Get one at https://ref.tools"
}

# Collect common development secrets
secrets_collect_dev() {
    tui_subheader "Development API Keys"
    echo ""
    
    secrets_prompt "GITHUB_TOKEN" "GitHub token" "For gh CLI and API access"
    secrets_prompt "ANTHROPIC_API_KEY" "Anthropic API key" "For Claude API access"
}

# =============================================================================
# Validation
# =============================================================================

# Verify secrets file has correct permissions
secrets_verify_permissions() {
    if secrets_exists; then
        local perms
        perms=$(stat -c "%a" "$SECRETS_FILE" 2>/dev/null || stat -f "%OLp" "$SECRETS_FILE" 2>/dev/null)
        if [[ "$perms" != "600" ]]; then
            tui_warning "Fixing permissions on $SECRETS_FILE"
            chmod 600 "$SECRETS_FILE"
        fi
    fi
}

# Check if .bashrc sources secrets
secrets_verify_bashrc() {
    local bashrc="$HOME/.bashrc"
    if [[ -f "$bashrc" ]]; then
        if ! grep -q '\[\[ -f ~/.secrets \]\] && source ~/.secrets' "$bashrc" && \
           ! grep -q '\[ -f ~/.secrets \] && source ~/.secrets' "$bashrc" && \
           ! grep -q 'source ~/.secrets' "$bashrc"; then
            tui_warning ".bashrc does not source ~/.secrets"
            tui_muted "Add this line to your .bashrc:"
            tui_muted '  [[ -f ~/.secrets ]] && source ~/.secrets'
            return 1
        fi
    fi
    return 0
}

# Check if current shell config sources secrets (bash or fish)
secrets_verify_shell() {
    local shell_pref="bash"
    [[ -f "$HOME/.config/omarchy/shell" ]] && shell_pref=$(cat "$HOME/.config/omarchy/shell")

    if [[ "$shell_pref" == "fish" ]]; then
        local fish_config="$HOME/.config/fish/config.fish"
        if [[ -f "$fish_config" ]] && grep -q '\.secrets' "$fish_config"; then
            return 0
        fi
        tui_warning "Fish config doesn't source ~/.secrets"
        tui_muted "Run 'omarchy shell fish' to reconfigure"
        return 1
    else
        return secrets_verify_bashrc
    fi
}

# =============================================================================
# Display
# =============================================================================

# Show status of known secrets (masked)
secrets_status() {
    tui_subheader "Secrets Status"
    echo ""
    
    local keys=("TAVILY_API_KEY" "REF_API_KEY" "GITHUB_TOKEN" "ANTHROPIC_API_KEY")
    
    for key in "${keys[@]}"; do
        local value
        value=$(secrets_get "$key")
        if [[ -n "$value" ]]; then
            local masked="${value:0:4}...${value: -4}"
            tui_success "$key: $masked"
        else
            tui_muted "$key: (not set)"
        fi
    done
    echo ""
}
