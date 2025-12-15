#!/bin/bash
# Package Registry & Installation Library
# Single source of truth for optional packages
# Source this file: source "$(dirname "$0")/lib/packages.sh"

# Requires: lib/tui.sh to be sourced first

# =============================================================================
# Package Registry
# Format: "name|category|description|config_files|autostart_entry|post_install"
# 
# Fields:
#   name          - Package name for yay/pacman
#   category      - Grouping for display (Browser, Utilities, Development, etc.)
#   description   - Human-readable description
#   config_files  - Comma-separated config paths (relative to ~/.config) or "none"
#   autostart     - Hyprland exec-once entry or "none"
#   post_install  - Command to run after install or "none"
# =============================================================================

PACKAGE_REGISTRY=(
    # Browsers
    # Guard: command -v ensures graceful failure if not installed
    "google-chrome-beta|Browser|Default browser|none|exec-once = command -v google-chrome-beta &>/dev/null && uwsm-app -- google-chrome-beta|xdg-settings set default-web-browser google-chrome-beta.desktop"
    
    # Networking
    "tailscale|Networking|Mesh VPN with magic DNS|none|none|none"
    
    # Utilities
    "solaar|Utilities|Logitech device manager|none|exec-once = command -v solaar &>/dev/null && solaar --window=hide|none"
    "tree|Utilities|Directory tree viewer|none|none|none"
    "wev|Utilities|Wayland event viewer (debug)|none|none|none"
    "wget|Utilities|Network file downloader|none|none|none"
    "nautilus|Utilities|GNOME file manager|none|none|none"
    
    # Development
    "bun-bin|Development|Fast JavaScript runtime|none|none|none"
    "cursor-bin|Development|AI-first coding environment|Cursor/User|none|none"
)

# =============================================================================
# Registry Parsing
# =============================================================================

# Get field from registry entry
# Usage: pkg_get_field "$entry" "name|category|description|config|autostart|post_install"
pkg_get_field() {
    local entry="$1"
    local field="$2"
    
    IFS='|' read -r name category description config autostart post_install <<< "$entry"
    
    case "$field" in
        name)        echo "$name" ;;
        category)    echo "$category" ;;
        description) echo "$description" ;;
        config)      echo "$config" ;;
        autostart)   echo "$autostart" ;;
        post_install) echo "$post_install" ;;
    esac
}

# Get all package names
pkg_list_names() {
    for entry in "${PACKAGE_REGISTRY[@]}"; do
        pkg_get_field "$entry" "name"
    done
}

# Get entry by package name
pkg_get_entry() {
    local name="$1"
    for entry in "${PACKAGE_REGISTRY[@]}"; do
        if [[ "$(pkg_get_field "$entry" "name")" == "$name" ]]; then
            echo "$entry"
            return 0
        fi
    done
    return 1
}

# Get packages by category
pkg_list_by_category() {
    local target_category="$1"
    for entry in "${PACKAGE_REGISTRY[@]}"; do
        local category
        category=$(pkg_get_field "$entry" "category")
        if [[ "$category" == "$target_category" ]]; then
            pkg_get_field "$entry" "name"
        fi
    done
}

# Get unique categories
pkg_list_categories() {
    local categories=()
    for entry in "${PACKAGE_REGISTRY[@]}"; do
        local category
        category=$(pkg_get_field "$entry" "category")
        if [[ ! " ${categories[*]} " =~ " ${category} " ]]; then
            categories+=("$category")
            echo "$category"
        fi
    done
}

# =============================================================================
# Installation Status
# =============================================================================

# Check if package is installed
pkg_is_installed() {
    local name="$1"
    pacman -Qi "$name" &>/dev/null
}

# Get list of installed packages from registry
pkg_list_installed() {
    for entry in "${PACKAGE_REGISTRY[@]}"; do
        local name
        name=$(pkg_get_field "$entry" "name")
        if pkg_is_installed "$name"; then
            echo "$name"
        fi
    done
}

# Get list of not-installed packages from registry
pkg_list_available() {
    for entry in "${PACKAGE_REGISTRY[@]}"; do
        local name
        name=$(pkg_get_field "$entry" "name")
        if ! pkg_is_installed "$name"; then
            echo "$name"
        fi
    done
}

# =============================================================================
# Display Functions
# =============================================================================

# Display packages in formatted table
pkg_display_all() {
    local current_category=""
    
    for entry in "${PACKAGE_REGISTRY[@]}"; do
        local name category description
        name=$(pkg_get_field "$entry" "name")
        category=$(pkg_get_field "$entry" "category")
        description=$(pkg_get_field "$entry" "description")
        
        # Print category header on change
        if [[ "$category" != "$current_category" ]]; then
            if [[ -n "$current_category" ]]; then
                echo ""
            fi
            tui_muted "── $category ──"
            current_category="$category"
        fi
        
        # Show install status
        local status_icon
        if pkg_is_installed "$name"; then
            status_icon="✓"
        else
            status_icon=" "
        fi
        
        printf "  [%s] %-24s %s\n" "$status_icon" "$name" "$description"
    done
}

# Display only available (not installed) packages
pkg_display_available() {
    echo ""
    for entry in "${PACKAGE_REGISTRY[@]}"; do
        local name description
        name=$(pkg_get_field "$entry" "name")
        description=$(pkg_get_field "$entry" "description")
        
        if ! pkg_is_installed "$name"; then
            printf "  %-24s %s\n" "$name" "$description"
        fi
    done
}

# =============================================================================
# Installation Functions
# =============================================================================

# Install a single package
# Returns: 0 on success, 1 on failure
pkg_install_one() {
    local name="$1"
    
    if pkg_is_installed "$name"; then
        tui_muted "$name already installed"
        return 0
    fi
    
    local output
    if output=$(yay -S --noconfirm "$name" 2>&1); then
        # Run post-install command if defined
        local entry post_install
        entry=$(pkg_get_entry "$name")
        if [[ -n "$entry" ]]; then
            post_install=$(pkg_get_field "$entry" "post_install")
            if [[ "$post_install" != "none" && -n "$post_install" ]]; then
                eval "$post_install" 2>/dev/null || true
            fi
        fi
        return 0
    else
        echo "$output" | tail -3
        return 1
    fi
}

# Install multiple packages with progress
pkg_install_many() {
    local -a packages=("$@")
    local total=${#packages[@]}
    local current=0
    local -a failed=()
    local -a skipped=()
    
    for name in "${packages[@]}"; do
        current=$((current + 1))
        
        if pkg_is_installed "$name"; then
            tui_step "$current" "$total" "$name (already installed)"
            skipped+=("$name")
            continue
        fi
        
        if tui_spin "[$current/$total] Installing $name..." yay -S --noconfirm "$name"; then
            # Run post-install
            local entry post_install
            entry=$(pkg_get_entry "$name")
            if [[ -n "$entry" ]]; then
                post_install=$(pkg_get_field "$entry" "post_install")
                if [[ "$post_install" != "none" && -n "$post_install" ]]; then
                    eval "$post_install" 2>/dev/null || true
                fi
            fi
            tui_success "$name installed"
        else
            tui_error "Failed to install $name"
            failed+=("$name")
        fi
    done
    
    # Summary
    echo ""
    if [[ ${#skipped[@]} -gt 0 ]]; then
        tui_info "${#skipped[@]} packages were already installed"
    fi
    
    if [[ ${#failed[@]} -gt 0 ]]; then
        tui_warning "${#failed[@]} packages failed to install:"
        for name in "${failed[@]}"; do
            tui_muted "  yay -S $name"
        done
        return 1
    fi
    
    return 0
}

# =============================================================================
# Interactive Selection
# =============================================================================

# Interactive package selection using gum
pkg_select_interactive() {
    local -a available=()
    local -a display_items=()
    
    # Build list of available packages
    for entry in "${PACKAGE_REGISTRY[@]}"; do
        local name description
        name=$(pkg_get_field "$entry" "name")
        description=$(pkg_get_field "$entry" "description")
        
        if ! pkg_is_installed "$name"; then
            available+=("$name")
            display_items+=("$name - $description")
        fi
    done
    
    if [[ ${#available[@]} -eq 0 ]]; then
        tui_success "All packages already installed!"
        return 0
    fi
    
    # Use gum for selection
    local selected
    selected=$(printf '%s\n' "${display_items[@]}" | tui_choose_multi "Select packages to install:")
    
    if [[ -z "$selected" ]]; then
        tui_muted "No packages selected"
        return 0
    fi
    
    # Extract package names from selection
    local -a to_install=()
    while IFS= read -r line; do
        # Extract package name (before " - ")
        local name="${line%% - *}"
        to_install+=("$name")
    done <<< "$selected"
    
    # Confirm and install
    echo ""
    tui_info "Selected ${#to_install[@]} packages:"
    for name in "${to_install[@]}"; do
        tui_muted "  $name"
    done
    echo ""
    
    if tui_confirm "Install these packages?"; then
        pkg_install_many "${to_install[@]}"
    else
        tui_muted "Installation cancelled"
    fi
}

# =============================================================================
# Autostart Generation
# =============================================================================

# Generate autostart entries for installed packages (to stdout)
pkg_generate_autostart() {
    local current_category=""
    
    echo "# Auto-generated autostart entries from package registry"
    echo "# Regenerate: source lib/packages.sh && pkg_generate_autostart"
    echo "# All entries use guards for graceful degradation"
    echo ""
    
    for entry in "${PACKAGE_REGISTRY[@]}"; do
        local name category autostart
        name=$(pkg_get_field "$entry" "name")
        category=$(pkg_get_field "$entry" "category")
        autostart=$(pkg_get_field "$entry" "autostart")
        
        if [[ "$autostart" != "none" && -n "$autostart" ]]; then
            # Print category header on change
            if [[ "$category" != "$current_category" ]]; then
                [[ -n "$current_category" ]] && echo ""
                echo "# ─── $category ───"
                current_category="$category"
            fi
            
            if pkg_is_installed "$name"; then
                echo "$autostart"
            else
                echo "# $autostart  # Not installed: $name"
            fi
        fi
    done
}

# Write autostart-apps.conf file
# Usage: pkg_write_autostart_file [path]
pkg_write_autostart_file() {
    local target="${1:-$HOME/.config/hypr/autostart-apps.conf}"
    local temp_file
    temp_file=$(mktemp)
    
    {
        echo "# App autostart - generated from package registry"
        echo "# Regenerate with: ./install.sh or source lib/packages.sh && pkg_write_autostart_file"
        echo "# All entries use guards to handle missing apps gracefully"
        echo ""
        echo "# ─── Core Apps (always installed) ───"
        echo "exec-once = uwsm-app -- 1password --silent"
        echo "exec-once = command -v localsend &>/dev/null && uwsm-app -- localsend --hidden"
        echo ""
        
        # Add registry entries
        local current_category=""
        for entry in "${PACKAGE_REGISTRY[@]}"; do
            local name category autostart
            name=$(pkg_get_field "$entry" "name")
            category=$(pkg_get_field "$entry" "category")
            autostart=$(pkg_get_field "$entry" "autostart")
            
            if [[ "$autostart" != "none" && -n "$autostart" ]]; then
                # Print category header on change
                if [[ "$category" != "$current_category" ]]; then
                    echo ""
                    echo "# ─── $category ───"
                    current_category="$category"
                fi
                
                if pkg_is_installed "$name"; then
                    echo "$autostart"
                else
                    echo "# $autostart  # Not installed: $name"
                fi
            fi
        done
    } > "$temp_file"
    
    # Only update if content changed
    if [[ -f "$target" ]] && diff -q "$temp_file" "$target" &>/dev/null; then
        rm "$temp_file"
        return 0
    fi
    
    mv "$temp_file" "$target"
    return 0
}

# Get autostart entry for a specific package
pkg_get_autostart() {
    local name="$1"
    local entry
    entry=$(pkg_get_entry "$name")
    if [[ -n "$entry" ]]; then
        pkg_get_field "$entry" "autostart"
    fi
}
