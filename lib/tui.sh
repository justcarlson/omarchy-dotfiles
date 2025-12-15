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
# Debug Output (enabled by OMARCHY_DEBUG=1 or --debug flag)
# =============================================================================
_debug() {
    if [[ "${OMARCHY_DEBUG:-}" == "1" ]]; then
        echo "[DEBUG tui] $*" >&2
    fi
    return 0  # Always succeed to avoid set -e issues
}

# =============================================================================
# Gum Detection & Fallback
# =============================================================================
_has_gum() {
    command -v gum &>/dev/null
}

# Check if /dev/tty is available for interactive input
_has_tty() {
    # First check if /dev/tty exists as a character device
    [[ -c /dev/tty ]] || return 1
    # Then try to read from it (silently)
    ( : </dev/tty ) 2>/dev/null
}

# Check gum version (0.14+ recommended for reliable TTY handling)
_gum_version_ok() {
    local version
    version=$(gum --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1)
    if [[ -z "$version" ]]; then
        return 1
    fi
    local major minor
    major="${version%%.*}"
    minor="${version#*.}"
    # Version 0.14+ is recommended
    [[ "$major" -gt 0 ]] || [[ "$major" -eq 0 && "$minor" -ge 14 ]]
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
        if ! _gum_version_ok; then
            _debug "gum version check: 0.14+ recommended, current: $(gum --version 2>/dev/null | head -1)"
        fi
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
    _debug "tui_choose called with $# args: $*"
    
    if [[ $# -eq 0 ]]; then
        _debug "tui_choose: no options provided"
        return 1
    fi
    
    if _has_gum && _has_tty; then
        local tmpfile result exit_code
        tmpfile=$(_tui_mktemp)
        
        # Render to /dev/tty, capture result to tmpfile
        gum choose "$@" > "$tmpfile" </dev/tty 2>/dev/tty
        exit_code=$?
        result=$(cat "$tmpfile")
        
        _debug "tui_choose: gum exit=$exit_code result='$result'"
        
        if [[ $exit_code -eq 0 && -n "$result" ]]; then
            echo "$result"
            return 0
        fi
    fi
    
    _debug "tui_choose: falling back to text mode"
    
    # Text-based fallback
    local i=1
    if _has_tty; then
        for opt in "$@"; do
            echo "  $i. $opt" >/dev/tty
            i=$((i + 1))
        done
        local num
        read -p "Enter number: " num </dev/tty
    else
        # No TTY available - print to stderr, read from stdin
        for opt in "$@"; do
            echo "  $i. $opt" >&2
            i=$((i + 1))
        done
        local num
        read -p "Enter number: " num
    fi
    
    if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "$#" ]; then
        echo "${!num}"
        return 0
    fi
    
    _debug "tui_choose: invalid selection '$num'"
    return 1
}

# Multi-selection from list
# Usage: 
#   choices=$(tui_choose_multi "header" "opt1" "opt2")     # Arguments
#   choices=$(printf 'opt1\nopt2' | tui_choose_multi "header")  # Piped input
# Returns: newline-separated list of selected items
tui_choose_multi() {
    local header="$1"
    shift
    
    _debug "tui_choose_multi called with header='$header', $# args"
    
    # Collect options from both piped stdin AND arguments
    local -a options=()
    
    # Check if stdin has piped data (not a TTY)
    if [[ ! -t 0 ]]; then
        _debug "tui_choose_multi: reading from piped stdin"
        while IFS= read -r line; do
            [[ -n "$line" ]] && options+=("$line")
        done
        _debug "tui_choose_multi: read ${#options[@]} options from stdin"
    fi
    
    # Also add any passed arguments
    if [[ $# -gt 0 ]]; then
        options+=("$@")
        _debug "tui_choose_multi: added $# options from args"
    fi
    
    if [[ ${#options[@]} -eq 0 ]]; then
        _debug "tui_choose_multi: no options provided"
        return 1
    fi
    
    _debug "tui_choose_multi: total ${#options[@]} options"
    
    if _has_gum && _has_tty; then
        local tmpfile result
        tmpfile=$(_tui_mktemp)
        gum choose --no-limit --header "$header" "${options[@]}" > "$tmpfile" </dev/tty 2>/dev/tty
        result=$(cat "$tmpfile")
        _debug "tui_choose_multi: gum result='$result'"
        echo "$result"
        return 0
    fi
    
    _debug "tui_choose_multi: falling back to text mode"
    
    # Text fallback
    local output_fd=2  # stderr by default
    local input_source="/dev/tty"
    
    if _has_tty; then
        output_fd="/dev/tty"
        input_source="/dev/tty"
    fi
    
    if _has_tty; then
        echo "$header" >/dev/tty
        local i=1
        for opt in "${options[@]}"; do
            echo "  $i. $opt" >/dev/tty
            i=$((i + 1))
        done
        echo "" >/dev/tty
        echo "Enter numbers separated by spaces (or Enter for all):" >/dev/tty
        local selection
        read -r selection </dev/tty
    else
        echo "$header" >&2
        local i=1
        for opt in "${options[@]}"; do
            echo "  $i. $opt" >&2
            i=$((i + 1))
        done
        echo "" >&2
        echo "Enter numbers separated by spaces (or Enter for all):" >&2
        local selection
        read -r selection
    fi
    
    if [[ -z "$selection" ]]; then
        printf '%s\n' "${options[@]}"
    else
        for num in $selection; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [[ "$num" -ge 1 ]] && [[ "$num" -le "${#options[@]}" ]]; then
                echo "${options[$((num-1))]}"
            fi
        done
    fi
}

# Fuzzy filter from stdin
# Usage: selected=$(echo -e "opt1\nopt2\nopt3" | tui_filter "Search:")
tui_filter() {
    local placeholder="${1:-Search...}"
    
    _debug "tui_filter called with placeholder='$placeholder'"
    
    # Capture piped input to temp file BEFORE redirecting stdin
    local input_file
    input_file=$(_tui_mktemp)
    cat > "$input_file"
    
    if [[ ! -s "$input_file" ]]; then
        _debug "tui_filter: no input provided"
        return 1
    fi
    
    _debug "tui_filter: captured $(wc -l < "$input_file") lines of input"
    
    if _has_gum && _has_tty; then
        local tmpfile result
        tmpfile=$(_tui_mktemp)
        # Feed saved input to gum, render UI to /dev/tty, capture result
        gum filter --placeholder "$placeholder" < "$input_file" > "$tmpfile" 2>/dev/tty
        result=$(cat "$tmpfile")
        _debug "tui_filter: gum result='$result'"
        echo "$result"
        return 0
    fi
    
    _debug "tui_filter: falling back to tui_choose"
    
    # Fallback: use tui_choose with the captured input
    local -a items=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && items+=("$line")
    done < "$input_file"
    
    if [[ ${#items[@]} -gt 0 ]]; then
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
