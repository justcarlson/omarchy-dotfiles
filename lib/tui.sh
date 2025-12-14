#!/bin/bash
# TUI Helper Library - Gum wrappers for consistent styling
# Source this file: source "$(dirname "$0")/lib/tui.sh"

# =============================================================================
# Theme Configuration
# =============================================================================
export TUI_COLOR_PRIMARY="212"      # Pink/magenta - headers, emphasis
export TUI_COLOR_SUCCESS="82"       # Green - success messages
export TUI_COLOR_ERROR="196"        # Red - error messages
export TUI_COLOR_WARNING="214"      # Orange/yellow - warnings
export TUI_COLOR_INFO="99"          # Purple - info, step indicators
export TUI_COLOR_MUTED="242"        # Gray - secondary text
export TUI_COLOR_BORDER="99"        # Purple - borders

# =============================================================================
# Gum Detection & Fallback
# =============================================================================
_has_gum() {
    command -v gum &>/dev/null
}

# =============================================================================
# Tmpfile Cleanup
# =============================================================================
_TUI_TMPFILES=()

_tui_cleanup_tmpfiles() {
    for f in "${_TUI_TMPFILES[@]}"; do
        rm -f "$f" 2>/dev/null
    done
}

# Register cleanup on exit
trap _tui_cleanup_tmpfiles EXIT

# Helper to create tracked tmpfile
_tui_mktemp() {
    local tmpfile
    tmpfile=$(mktemp)
    _TUI_TMPFILES+=("$tmpfile")
    echo "$tmpfile"
}

# Install gum if missing (called once at script start)
tui_ensure_gum() {
    if _has_gum; then
        return 0
    fi
    
    echo "Installing gum for better UI..."
    if command -v yay &>/dev/null; then
        if yay -S --noconfirm gum &>/dev/null; then
            echo "Gum installed successfully"
            return 0
        fi
    fi
    
    echo "Warning: Could not install gum. Using basic prompts."
    return 1
}

# =============================================================================
# Section Headers
# =============================================================================
tui_header() {
    local title="$1"
    if _has_gum; then
        echo ""
        gum style \
            --foreground "$TUI_COLOR_PRIMARY" \
            --border double \
            --border-foreground "$TUI_COLOR_BORDER" \
            --align center \
            --width 50 \
            --padding "0 2" \
            "$title"
        echo ""
    else
        echo ""
        echo "======================================"
        echo "  $title"
        echo "======================================"
        echo ""
    fi
}

tui_subheader() {
    local title="$1"
    if _has_gum; then
        gum style \
            --foreground "$TUI_COLOR_INFO" \
            --border rounded \
            --border-foreground "$TUI_COLOR_MUTED" \
            --padding "0 2" \
            "$title"
    else
        echo "--------------------------------------"
        echo "  $title"
        echo "--------------------------------------"
    fi
}

# =============================================================================
# Status Messages
# =============================================================================
tui_success() {
    local message="$1"
    if _has_gum; then
        gum style --foreground "$TUI_COLOR_SUCCESS" "✓ $message"
    else
        echo "✓ $message"
    fi
}

tui_error() {
    local message="$1"
    if _has_gum; then
        gum style --foreground "$TUI_COLOR_ERROR" "✗ $message"
    else
        echo "✗ $message" >&2
    fi
}

tui_warning() {
    local message="$1"
    if _has_gum; then
        gum style --foreground "$TUI_COLOR_WARNING" "⚠ $message"
    else
        echo "⚠ $message"
    fi
}

tui_info() {
    local message="$1"
    if _has_gum; then
        gum style --foreground "$TUI_COLOR_INFO" "ℹ $message"
    else
        echo "ℹ $message"
    fi
}

tui_muted() {
    local message="$1"
    if _has_gum; then
        gum style --foreground "$TUI_COLOR_MUTED" "  $message"
    else
        echo "  $message"
    fi
}

# =============================================================================
# Progress Indicators
# =============================================================================
tui_step() {
    local current="$1"
    local total="$2"
    local message="$3"
    if _has_gum; then
        gum style --foreground "$TUI_COLOR_INFO" --bold "[$current/$total] $message"
    else
        echo "[$current/$total] $message"
    fi
}

# Run command with spinner
# Usage: tui_spin "Installing package..." yay -S --noconfirm pkg
tui_spin() {
    local title="$1"
    shift
    if _has_gum; then
        gum spin --spinner dot --title "$title" -- "$@"
    else
        echo "$title"
        "$@"
    fi
}

# =============================================================================
# User Input
# =============================================================================

# Confirmation prompt
# Usage: tui_confirm "Proceed?" && do_thing
# Returns: 0 for yes, 1 for no, 130 for cancel
tui_confirm() {
    local prompt="$1"
    local default="${2:-true}"  # Default to yes
    
    if _has_gum; then
        if [[ "$default" == "true" ]]; then
            gum confirm "$prompt" --default=true </dev/tty >/dev/tty 2>/dev/tty
        else
            gum confirm "$prompt" --default=false </dev/tty >/dev/tty 2>/dev/tty
        fi
    else
        local yn
        if [[ "$default" == "true" ]]; then
            read -p "$prompt [Y/n]: " -n 1 -r yn </dev/tty
        else
            read -p "$prompt [y/N]: " -n 1 -r yn </dev/tty
        fi
        echo "" >/dev/tty
        
        if [[ "$default" == "true" ]]; then
            [[ ! "${yn,,}" == "n" ]]
        else
            [[ "${yn,,}" == "y" ]]
        fi
    fi
}

# Text input
# Usage: value=$(tui_input "Enter name" "placeholder text")
tui_input() {
    local prompt="$1"
    local placeholder="${2:-}"
    
    if _has_gum; then
        local tmpfile result
        tmpfile=$(_tui_mktemp)
        gum input --prompt "$prompt: " --placeholder "$placeholder" > "$tmpfile" </dev/tty 2>/dev/tty
        result=$(cat "$tmpfile")
        echo "$result"
    else
        local value
        read -p "$prompt: " value </dev/tty
        echo "$value"
    fi
}

# Password/secret input (masked)
# Usage: secret=$(tui_secret "API Key" "paste key here")
tui_secret() {
    local prompt="$1"
    local placeholder="${2:-}"
    
    if _has_gum; then
        local tmpfile result
        tmpfile=$(_tui_mktemp)
        gum input --password --prompt "$prompt: " --placeholder "$placeholder" > "$tmpfile" </dev/tty 2>/dev/tty
        result=$(cat "$tmpfile")
        echo "$result"
    else
        local value
        read -s -p "$prompt: " value </dev/tty
        echo "" >/dev/tty  # Newline after hidden input
        echo "$value"
    fi
}

# =============================================================================
# Selection
# =============================================================================

# Single selection from list
# Usage: choice=$(tui_choose "Option 1" "Option 2" "Option 3")
tui_choose() {
    if _has_gum; then
        local tmpfile result exit_code
        tmpfile=$(_tui_mktemp)
        
        # Render to /dev/tty, capture result to tmpfile
        gum choose "$@" > "$tmpfile" </dev/tty 2>/dev/tty
        exit_code=$?
        result=$(cat "$tmpfile")
        
        if [[ $exit_code -eq 0 && -n "$result" ]]; then
            echo "$result"
            return 0
        fi
    fi
    
    # Text-based fallback (render to /dev/tty, read from /dev/tty)
    local i=1
    for opt in "$@"; do
        echo "  $i. $opt" >/dev/tty
        i=$((i + 1))
    done
    local num
    read -p "Enter number: " num </dev/tty
    if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "$#" ]; then
        echo "${!num}"
    fi
}

# Multi-selection from list
# Usage: choices=$(tui_choose_multi "header text" "opt1" "opt2" "opt3")
# Returns: newline-separated list of selected items
tui_choose_multi() {
    local header="$1"
    shift
    
    if _has_gum; then
        local tmpfile result
        tmpfile=$(_tui_mktemp)
        gum choose --no-limit --header "$header" "$@" > "$tmpfile" </dev/tty 2>/dev/tty
        result=$(cat "$tmpfile")
        echo "$result"
    else
        # Text fallback - render to /dev/tty
        echo "$header" >/dev/tty
        local i=1
        for opt in "$@"; do
            echo "  $i. $opt" >/dev/tty
            i=$((i + 1))
        done
        echo "" >/dev/tty
        echo "Enter numbers separated by spaces (or Enter for all):" >/dev/tty
        local selection
        read -r selection </dev/tty
        
        if [ -z "$selection" ]; then
            printf '%s\n' "$@"
        else
            for num in $selection; do
                if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "$#" ]; then
                    local idx=$((num))
                    echo "${!idx}"
                fi
            done
        fi
    fi
}

# Fuzzy filter from stdin
# Usage: selected=$(echo -e "opt1\nopt2\nopt3" | tui_filter "Search:")
tui_filter() {
    local placeholder="${1:-Search...}"
    
    if _has_gum; then
        local tmpfile result
        tmpfile=$(_tui_mktemp)
        # Pipe stdin to gum, render UI to /dev/tty, capture result
        gum filter --placeholder "$placeholder" > "$tmpfile" </dev/tty 2>/dev/tty
        result=$(cat "$tmpfile")
        echo "$result"
    else
        # Fallback: just use choose
        local items=()
        while IFS= read -r line; do
            items+=("$line")
        done
        tui_choose "${items[@]}"
    fi
}

# =============================================================================
# Display Helpers
# =============================================================================

# Display a boxed message
tui_box() {
    local message="$1"
    if _has_gum; then
        gum style \
            --border rounded \
            --border-foreground "$TUI_COLOR_MUTED" \
            --padding "1 2" \
            "$message"
    else
        echo "┌────────────────────────────────────┐"
        echo "│ $message"
        echo "└────────────────────────────────────┘"
    fi
}

# Display key-value pair
tui_kv() {
    local key="$1"
    local value="$2"
    if _has_gum; then
        echo "$(gum style --foreground "$TUI_COLOR_MUTED" "$key:") $value"
    else
        echo "$key: $value"
    fi
}

# =============================================================================
# Trap Handler for Clean Exit
# =============================================================================
tui_setup_trap() {
    trap '_tui_cleanup' SIGINT SIGTERM
}

_tui_cleanup() {
    echo ""
    tui_warning "Installation cancelled."
    exit 130
}

# =============================================================================
# Utility Functions
# =============================================================================

# Check if running in dry-run mode (set by install.sh)
tui_is_dry_run() {
    [[ "${DRY_RUN:-false}" == "true" ]]
}

# Execute command only if not in dry-run mode
# Usage: tui_exec "description" command args...
tui_exec() {
    local description="$1"
    shift
    
    if tui_is_dry_run; then
        tui_info "[DRY RUN] Would: $description"
        return 0
    fi
    
    "$@"
}
