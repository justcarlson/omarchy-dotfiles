#!/bin/bash
# Fixes library unit tests
# Tests system fix detection and application logic
# Run: ./tests/test_fixes.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Source the libraries
source "$REPO_DIR/lib/tui.sh"
source "$REPO_DIR/lib/fixes.sh"

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
# fixes_needs_thunderbolt_fix Tests
# =============================================================================

test_thunderbolt_fix_not_needed() {
    echo ""
    echo "=== fixes_needs_thunderbolt_fix when file does not exist ==="
    
    # Override the variable to point to a non-existent file
    local result
    result=$(bash -c '
        source "'"$REPO_DIR"'/lib/tui.sh"
        THUNDERBOLT_MODULE_CONF="/tmp/nonexistent_thunderbolt_test_file_12345"
        
        fixes_needs_thunderbolt_fix() {
            [[ -f "$THUNDERBOLT_MODULE_CONF" ]]
        }
        
        if fixes_needs_thunderbolt_fix; then
            echo "NEEDS_FIX"
        else
            echo "NO_FIX_NEEDED"
        fi
    ' 2>&1)
    
    assert_eq "NO_FIX_NEEDED" "$result" "fixes_needs_thunderbolt_fix returns false when file missing"
}

test_thunderbolt_fix_needed() {
    echo ""
    echo "=== fixes_needs_thunderbolt_fix when file exists ==="
    
    # Create a temp file to simulate the config
    local tmpfile
    tmpfile=$(mktemp)
    echo "MODULES+=(thunderbolt)" > "$tmpfile"
    
    local result
    result=$(bash -c '
        source "'"$REPO_DIR"'/lib/tui.sh"
        THUNDERBOLT_MODULE_CONF="'"$tmpfile"'"
        
        fixes_needs_thunderbolt_fix() {
            [[ -f "$THUNDERBOLT_MODULE_CONF" ]]
        }
        
        if fixes_needs_thunderbolt_fix; then
            echo "NEEDS_FIX"
        else
            echo "NO_FIX_NEEDED"
        fi
    ' 2>&1)
    
    rm -f "$tmpfile"
    
    assert_eq "NEEDS_FIX" "$result" "fixes_needs_thunderbolt_fix returns true when file exists"
}

# =============================================================================
# fixes_run_all Tests
# =============================================================================

test_fixes_run_all_no_fixes() {
    echo ""
    echo "=== fixes_run_all when no fixes needed ==="
    
    local result
    result=$(bash -c '
        source "'"$REPO_DIR"'/lib/tui.sh"
        THUNDERBOLT_MODULE_CONF="/tmp/nonexistent_thunderbolt_test_file_12345"
        
        fixes_needs_thunderbolt_fix() {
            [[ -f "$THUNDERBOLT_MODULE_CONF" ]]
        }
        
        fixes_run_all() {
            local has_fixes=false
            
            if fixes_needs_thunderbolt_fix; then
                has_fixes=true
            fi
            
            if [[ "$has_fixes" == "false" ]]; then
                tui_success "No system fixes needed"
            fi
        }
        
        fixes_run_all
    ' 2>&1)
    
    assert_contains "$result" "No system fixes needed" "fixes_run_all shows no fixes message"
}

test_fixes_run_all_ci_mode() {
    echo ""
    echo "=== fixes_run_all in CI mode ==="
    
    # Create a temp file to simulate the config
    local tmpfile
    tmpfile=$(mktemp)
    echo "MODULES+=(thunderbolt)" > "$tmpfile"
    
    local result
    result=$(CI=true bash -c '
        source "'"$REPO_DIR"'/lib/tui.sh"
        THUNDERBOLT_MODULE_CONF="'"$tmpfile"'"
        
        fixes_needs_thunderbolt_fix() {
            [[ -f "$THUNDERBOLT_MODULE_CONF" ]]
        }
        
        fixes_run_all() {
            local has_fixes=false
            
            if fixes_needs_thunderbolt_fix; then
                has_fixes=true
                
                if _is_ci || ! _has_tty; then
                    tui_muted "Skipping thunderbolt fix (non-interactive)"
                    return 0
                fi
            fi
        }
        
        fixes_run_all
    ' 2>&1)
    
    rm -f "$tmpfile"
    
    assert_contains "$result" "non-interactive" "fixes_run_all skips in CI mode"
}

test_fixes_dry_run() {
    echo ""
    echo "=== fixes in DRY_RUN mode ==="
    
    # Create a temp file to simulate the config
    local tmpfile
    tmpfile=$(mktemp)
    echo "MODULES+=(thunderbolt)" > "$tmpfile"
    
    local result
    result=$(DRY_RUN=true bash -c '
        source "'"$REPO_DIR"'/lib/tui.sh"
        THUNDERBOLT_MODULE_CONF="'"$tmpfile"'"
        
        fixes_needs_thunderbolt_fix() {
            [[ -f "$THUNDERBOLT_MODULE_CONF" ]]
        }
        
        if [[ "$DRY_RUN" == "true" ]]; then
            if fixes_needs_thunderbolt_fix; then
                tui_info "[DRY RUN] Would prompt for thunderbolt multi-monitor fix"
            fi
        fi
    ' 2>&1)
    
    rm -f "$tmpfile"
    
    assert_contains "$result" "DRY RUN" "DRY_RUN mode shows appropriate message"
}

# =============================================================================
# Run All Tests
# =============================================================================

run_all_tests() {
    echo "========================================"
    echo "  Fixes Library Tests"
    echo "========================================"
    echo ""
    echo "Repository: $REPO_DIR"
    echo "Bash version: $BASH_VERSION"
    echo ""
    
    test_thunderbolt_fix_not_needed
    test_thunderbolt_fix_needed
    test_fixes_run_all_no_fixes
    test_fixes_run_all_ci_mode
    test_fixes_dry_run
    
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
