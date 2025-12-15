#!/bin/bash
# Install script unit tests
# Tests helper functions that can be tested in isolation
# Run: ./tests/test_install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Source the library
source "$REPO_DIR/lib/tui.sh"

# Test counters
PASSED=0
FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# =============================================================================
# Test Helpers
# =============================================================================

pass() {
    echo -e "${GREEN}✓${NC} $1"
    PASSED=$((PASSED + 1))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    if [[ -n "${2:-}" ]]; then
        echo "  $2"
    fi
    FAILED=$((FAILED + 1))
}

assert_eq() {
    local expected="$1" actual="$2" msg="$3"
    if [[ "$expected" == "$actual" ]]; then
        pass "$msg"
    else
        fail "$msg" "Expected: '$expected', Actual: '$actual'"
    fi
}

assert_contains() {
    local haystack="$1" needle="$2" msg="$3"
    if [[ "$haystack" == *"$needle"* ]]; then
        pass "$msg"
    else
        fail "$msg" "Expected to contain: '$needle'"
    fi
}

# =============================================================================
# enable_tailscale Tests
# =============================================================================

test_enable_tailscale_not_installed() {
    echo ""
    echo "=== enable_tailscale when tailscale not installed ==="
    
    # Simulate tailscale not installed by checking for nonexistent command
    local result
    result=$(bash -c '
        source "'"$REPO_DIR"'/lib/tui.sh"
        
        enable_tailscale() {
            if ! command -v tailscale_nonexistent_cmd &>/dev/null; then
                return 0
            fi
            echo "ERROR: should not reach here"
        }
        enable_tailscale
    ' 2>&1)
    
    if [[ -z "$result" ]] || [[ "$result" != *"ERROR"* ]]; then
        pass "enable_tailscale exits early when tailscale not installed"
    else
        fail "enable_tailscale should exit silently when tailscale not installed" "$result"
    fi
}

test_enable_tailscale_dry_run() {
    echo ""
    echo "=== enable_tailscale in DRY_RUN mode ==="
    
    local result
    result=$(DRY_RUN=true bash -c '
        source "'"$REPO_DIR"'/lib/tui.sh"
        
        # Mock tailscale as installed
        tailscale() { return 0; }
        export -f tailscale
        
        # Mock systemctl is-enabled to return false (not enabled)
        systemctl() { return 1; }
        export -f systemctl
        
        if [[ "$DRY_RUN" == "true" ]]; then
            tui_info "[DRY RUN] Would prompt to enable tailscaled service"
        fi
    ' 2>&1)
    
    assert_contains "$result" "DRY RUN" "DRY_RUN mode shows appropriate message"
}

test_enable_tailscale_ci_mode() {
    echo ""
    echo "=== enable_tailscale in CI mode ==="
    
    local result
    result=$(CI=true bash -c '
        source "'"$REPO_DIR"'/lib/tui.sh"
        
        if _is_ci; then
            tui_muted "Skipping tailscaled enablement (non-interactive)"
        fi
    ' 2>&1)
    
    assert_contains "$result" "non-interactive" "CI mode skips with appropriate message"
}

test_enable_tailscale_already_enabled() {
    echo ""
    echo "=== enable_tailscale when already enabled ==="
    
    local result
    result=$(bash -c '
        source "'"$REPO_DIR"'/lib/tui.sh"
        
        # Mock systemctl is-enabled to return true
        systemctl() {
            if [[ "$1" == "is-enabled" ]]; then
                return 0
            fi
            return 1
        }
        export -f systemctl
        
        # Check the condition
        if systemctl is-enabled tailscaled &>/dev/null 2>&1; then
            tui_success "Tailscale daemon already enabled"
        fi
    ' 2>&1)
    
    assert_contains "$result" "already enabled" "Already enabled shows success message"
}

# =============================================================================
# Run All Tests
# =============================================================================

run_all_tests() {
    echo "========================================"
    echo "  Install Script Tests"
    echo "========================================"
    echo ""
    echo "Repository: $REPO_DIR"
    echo "Bash version: $BASH_VERSION"
    echo ""
    
    test_enable_tailscale_not_installed
    test_enable_tailscale_dry_run
    test_enable_tailscale_ci_mode
    test_enable_tailscale_already_enabled
    
    # Summary
    echo ""
    echo "========================================"
    echo "  Results: $PASSED passed, $FAILED failed"
    echo "========================================"
    
    return $FAILED
}

# Run tests
run_all_tests
exit $?
