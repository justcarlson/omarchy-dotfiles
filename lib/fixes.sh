#!/bin/bash
# System Fixes Library - Hardware-specific fixes for Omarchy
# Source this file: source "$(dirname "$0")/lib/fixes.sh"
# Dependencies: Requires lib/tui.sh to be sourced first (for _is_ci, _has_tty, tui_*)

# =============================================================================
# Configuration
# =============================================================================
THUNDERBOLT_MODULE_CONF="/etc/mkinitcpio.conf.d/thunderbolt_module.conf"
THUNDERBOLT_ISSUE_URL="https://github.com/basecamp/omarchy/issues/3906"

# =============================================================================
# Thunderbolt Multi-Monitor Fix
# =============================================================================
# Issue: Race condition in Omarchy v3.2.3 where thunderbolt module loads early
# in initramfs, tearing down DP tunnels before GPU driver initializes.
# Fix: Remove early thunderbolt loading to allow proper DP tunnel setup.
# Tradeoff: Plymouth boot splash won't show on external TB displays.

# Check if thunderbolt fix is applicable
fixes_needs_thunderbolt_fix() {
    [[ -f "$THUNDERBOLT_MODULE_CONF" ]]
}

# Apply the thunderbolt multi-monitor fix
# Returns: 0 on success, 1 on failure
fixes_apply_thunderbolt() {
    # Early sudo check to prevent partial failure
    if ! sudo -v 2>/dev/null; then
        tui_error "sudo authentication required"
        return 1
    fi
    
    # Remove the config file
    if sudo rm "$THUNDERBOLT_MODULE_CONF"; then
        tui_success "Removed $THUNDERBOLT_MODULE_CONF"
    else
        tui_error "Failed to remove $THUNDERBOLT_MODULE_CONF"
        return 1
    fi
    
    # Rebuild initramfs
    if tui_spin "Regenerating initramfs..." sudo mkinitcpio -P; then
        tui_success "Initramfs regenerated"
    else
        tui_error "Failed to regenerate initramfs"
        return 1
    fi
    
    tui_warning "Reboot required for fix to take effect"
    return 0
}

# =============================================================================
# Main Entry Point
# =============================================================================

# Run all applicable system fixes
# Checks for each known fix and prompts user to apply if needed
fixes_run_all() {
    local has_fixes=false
    
    # Check for thunderbolt fix
    if fixes_needs_thunderbolt_fix; then
        has_fixes=true
        
        tui_subheader "Thunderbolt Multi-Monitor Fix"
        echo ""
        tui_info "Detected: $THUNDERBOLT_MODULE_CONF"
        tui_muted "This file can cause multi-monitor issues on MacBooks with discrete GPUs."
        tui_muted "Removing it allows proper DP tunnel setup over Thunderbolt."
        tui_muted "Tracking: $THUNDERBOLT_ISSUE_URL"
        echo ""
        
        # CI/non-interactive check - skip (default: no action)
        if _is_ci || ! _has_tty; then
            tui_muted "Skipping thunderbolt fix (non-interactive)"
            tui_muted "Apply manually: sudo rm $THUNDERBOLT_MODULE_CONF && sudo mkinitcpio -P"
            return 0
        fi
        
        if tui_confirm "Apply fix (remove file and regenerate initramfs)?"; then
            if ! fixes_apply_thunderbolt; then
                tui_warning "Fix application failed - manual intervention may be required"
            fi
        else
            tui_muted "Skipping. Apply later with:"
            tui_muted "  sudo rm $THUNDERBOLT_MODULE_CONF && sudo mkinitcpio -P"
        fi
    fi
    
    if [[ "$has_fixes" == "false" ]]; then
        tui_success "No system fixes needed"
    fi
    
    return 0
}
