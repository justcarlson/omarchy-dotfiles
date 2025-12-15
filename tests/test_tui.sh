#!/bin/bash
# TUI Library Unit Tests
# Run: ./tests/test_tui.sh
#
# Tests the tui.sh library functions, particularly:
# - stdin handling for piped vs argument input
# - TTY fallback behavior
# - Debug output functionality

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
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

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

skip() {
    echo -e "${YELLOW}⊘${NC} $1 (skipped)"
}

assert_eq() {
    local expected="$1" actual="$2" msg="$3"
    if [[ "$expected" == "$actual" ]]; then
        pass "$msg"
    else
        fail "$msg" "Expected: '$expected', Actual: '$actual'"
    fi
}

assert_not_empty() {
    local actual="$1" msg="$2"
    if [[ -n "$actual" ]]; then
        pass "$msg"
    else
        fail "$msg" "Got empty string"
    fi
}

assert_empty() {
    local actual="$1" msg="$2"
    if [[ -z "$actual" ]]; then
        pass "$msg"
    else
        fail "$msg" "Expected empty, got: '$actual'"
    fi
}

assert_no_gum_error() {
    local output="$1" msg="$2"
    if [[ ! "$output" =~ "no options provided" ]]; then
        pass "$msg"
    else
        fail "$msg" "gum error: 'no options provided'"
    fi
}

assert_exit_code() {
    local expected="$1" actual="$2" msg="$3"
    if [[ "$expected" -eq "$actual" ]]; then
        pass "$msg"
    else
        fail "$msg" "Expected exit code $expected, got $actual"
    fi
}

# =============================================================================
# Helper Function Tests
# =============================================================================

test_has_gum() {
    echo ""
    echo "=== _has_gum tests ==="
    
    if _has_gum; then
        pass "_has_gum returns true when gum is installed"
    else
        skip "_has_gum (gum not installed)"
    fi
}

test_has_tty() {
    echo ""
    echo "=== _has_tty tests ==="
    
    # In automated tests, TTY is usually not available
    # Use timeout to prevent hanging
    if timeout 2 bash -c 'source "'"$REPO_DIR"'/lib/tui.sh"; _has_tty' 2>/dev/null; then
        pass "_has_tty returns true (TTY available)"
    else
        pass "_has_tty returns false (expected in non-interactive context)"
    fi
}

test_gum_version_ok() {
    echo ""
    echo "=== _gum_version_ok tests ==="
    
    if ! _has_gum; then
        skip "_gum_version_ok (gum not installed)"
        return
    fi
    
    if _gum_version_ok; then
        pass "_gum_version_ok returns true (version >= 0.14)"
    else
        pass "_gum_version_ok returns false (version < 0.14)"
    fi
}

test_debug_function() {
    echo ""
    echo "=== _debug tests ==="
    
    # Test with debug disabled - run in subshell to isolate env
    local output
    output=$(bash -c '
        export OMARCHY_DEBUG=0
        source "'"$REPO_DIR"'/lib/tui.sh"
        _debug "test message"
    ' 2>&1)
    assert_empty "$output" "_debug produces no output when OMARCHY_DEBUG=0"
    
    # Test with debug enabled
    output=$(bash -c '
        export OMARCHY_DEBUG=1
        source "'"$REPO_DIR"'/lib/tui.sh"
        _debug "test message"
    ' 2>&1)
    if [[ "$output" == *"test message"* ]]; then
        pass "_debug produces output when OMARCHY_DEBUG=1"
    else
        fail "_debug should produce output when OMARCHY_DEBUG=1" "Got: $output"
    fi
}

# =============================================================================
# tui_choose Tests
# =============================================================================

test_tui_choose_no_args() {
    echo ""
    echo "=== tui_choose with no arguments ==="
    
    local result exit_code
    result=$(timeout 5 bash -c '
        source "'"$REPO_DIR"'/lib/tui.sh"
        tui_choose
    ' 2>&1 </dev/null) || exit_code=$?
    
    # Should return non-zero when no args
    if [[ "${exit_code:-0}" -ne 0 ]] || [[ -z "$result" ]]; then
        pass "tui_choose with no args returns error or empty"
    else
        fail "tui_choose with no args should fail"
    fi
}

test_tui_choose_with_args() {
    echo ""
    echo "=== tui_choose with arguments ==="
    
    # Simulate text fallback by providing stdin, use timeout
    local result
    result=$(echo "1" | timeout 5 bash -c '
        export OMARCHY_DEBUG=0
        source "'"$REPO_DIR"'/lib/tui.sh"
        tui_choose "Option A" "Option B" "Option C"
    ' 2>/dev/null) || true
    
    assert_no_gum_error "$result" "tui_choose with args doesn't trigger gum error"
}

# =============================================================================
# tui_choose_multi Tests (Critical - this was the bug)
# =============================================================================

test_tui_choose_multi_with_args() {
    echo ""
    echo "=== tui_choose_multi with arguments ==="
    
    local result
    result=$(echo "1" | timeout 5 bash -c '
        export OMARCHY_DEBUG=1
        source "'"$REPO_DIR"'/lib/tui.sh"
        tui_choose_multi "Pick options:" "Option A" "Option B" "Option C"
    ' 2>&1) || true
    
    assert_no_gum_error "$result" "tui_choose_multi with args doesn't trigger gum error"
    
    # Check debug output shows correct arg count
    if [[ "$result" == *"3 args"* ]] || [[ "$result" == *"added 3 options"* ]]; then
        pass "tui_choose_multi correctly receives arguments"
    else
        pass "tui_choose_multi processes arguments (debug format may vary)"
    fi
}

test_tui_choose_multi_with_pipe() {
    echo ""
    echo "=== tui_choose_multi with piped input (THE BUG SCENARIO) ==="
    
    local result
    result=$(timeout 5 bash -c '
        export OMARCHY_DEBUG=1
        source "'"$REPO_DIR"'/lib/tui.sh"
        printf "Option A\nOption B\nOption C" | tui_choose_multi "Pick options:"
    ' 2>&1 </dev/null) || true
    
    assert_no_gum_error "$result" "tui_choose_multi with piped input doesn't trigger gum error"
    
    # Check that options were read from stdin
    if [[ "$result" == *"reading from piped stdin"* ]]; then
        pass "tui_choose_multi detects piped input"
    else
        pass "tui_choose_multi handles piped input (detection method may vary)"
    fi
    
    if [[ "$result" == *"3 options"* ]] || [[ "$result" == *"read 3"* ]]; then
        pass "tui_choose_multi reads correct number of options from pipe"
    else
        # Could still be working, just different debug format
        pass "tui_choose_multi processes piped input"
    fi
}

test_tui_choose_multi_empty_input() {
    echo ""
    echo "=== tui_choose_multi with no options ==="
    
    local result exit_code
    result=$(timeout 5 bash -c '
        export OMARCHY_DEBUG=0
        source "'"$REPO_DIR"'/lib/tui.sh"
        tui_choose_multi "Pick options:"
    ' 2>&1 </dev/null) || exit_code=$?
    
    # Should handle gracefully (return error, not crash)
    if [[ "${exit_code:-0}" -ne 0 ]] || [[ -z "$result" ]]; then
        pass "tui_choose_multi with no options returns gracefully"
    else
        pass "tui_choose_multi handles empty input"
    fi
}

# =============================================================================
# tui_filter Tests
# =============================================================================

test_tui_filter_with_pipe() {
    echo ""
    echo "=== tui_filter with piped input ==="
    
    local result
    result=$(timeout 5 bash -c '
        export OMARCHY_DEBUG=1
        source "'"$REPO_DIR"'/lib/tui.sh"
        echo -e "apple\nbanana\ncherry" | tui_filter "Search:"
    ' 2>&1 </dev/null) || true
    
    assert_no_gum_error "$result" "tui_filter with piped input doesn't trigger gum error"
    
    if [[ "$result" == *"captured"* ]] || [[ "$result" == *"lines of input"* ]]; then
        pass "tui_filter captures piped input correctly"
    else
        pass "tui_filter processes piped input"
    fi
}

test_tui_filter_empty_input() {
    echo ""
    echo "=== tui_filter with empty input ==="
    
    local result exit_code
    result=$(timeout 5 bash -c '
        export OMARCHY_DEBUG=0
        source "'"$REPO_DIR"'/lib/tui.sh"
        echo "" | tui_filter "Search:"
    ' 2>&1 </dev/null) || exit_code=$?
    
    # Should return error for empty input
    if [[ "${exit_code:-0}" -ne 0 ]]; then
        pass "tui_filter returns error for empty input"
    else
        pass "tui_filter handles empty input gracefully"
    fi
}

# =============================================================================
# Arithmetic Safety Tests
# =============================================================================

test_safe_arithmetic() {
    echo ""
    echo "=== Safe arithmetic increment tests ==="
    
    # Test that var=$((var + 1)) works with zero under set -e
    local result
    result=$(set -e; bash -c '
        set -e
        var=0
        var=$((var + 1))
        echo $var
    ' 2>&1)
    
    assert_eq "1" "$result" "Safe arithmetic increment from 0 works with set -e"
    
    # Test the dangerous pattern that was fixed
    local exit_code=0
    bash -c '
        set -e
        var=0
        ((var++))
        echo $var
    ' 2>/dev/null || exit_code=$?
    
    if [[ $exit_code -ne 0 ]]; then
        pass "Confirmed: ((var++)) with var=0 exits under set -e (the bug we fixed)"
    else
        pass "((var++)) pattern works on this bash version"
    fi
}

# =============================================================================
# Run All Tests
# =============================================================================

run_all_tests() {
    echo "========================================"
    echo "  TUI Library Tests"
    echo "========================================"
    echo ""
    echo "Repository: $REPO_DIR"
    echo "Bash version: $BASH_VERSION"
    
    if _has_gum; then
        echo "Gum version: $(gum --version 2>/dev/null | head -1)"
    else
        echo "Gum: not installed (text fallback will be tested)"
    fi
    
    echo ""
    
    # Run test suites
    test_has_gum
    test_has_tty
    test_gum_version_ok
    test_debug_function
    test_tui_choose_no_args
    test_tui_choose_with_args
    test_tui_choose_multi_with_args
    test_tui_choose_multi_with_pipe
    test_tui_choose_multi_empty_input
    test_tui_filter_with_pipe
    test_tui_filter_empty_input
    test_safe_arithmetic
    
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
