#!/bin/bash
# Test Runner - Run all tests in the tests/ directory
# Usage: ./tests/run_tests.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "  Omarchy Dotfiles Test Suite"
echo "========================================"
echo ""

total_passed=0
total_failed=0
suites_run=0
suites_failed=0

# Run each test file
for test_file in "$SCRIPT_DIR"/test_*.sh; do
    if [[ -f "$test_file" ]]; then
        test_name=$(basename "$test_file" .sh)
        echo ">>> Running: $test_name"
        echo ""
        
        if bash "$test_file"; then
            echo ""
            ((suites_run++))
        else
            exit_code=$?
            echo ""
            echo "Suite $test_name had failures"
            ((suites_run++))
            ((suites_failed++))
        fi
        
        echo "----------------------------------------"
        echo ""
    fi
done

# Final summary
echo "========================================"
echo "  Final Summary"
echo "========================================"
echo ""
echo "Test suites run: $suites_run"
echo "Test suites with failures: $suites_failed"
echo ""

if [[ $suites_failed -eq 0 ]]; then
    echo "All test suites passed!"
    exit 0
else
    echo "$suites_failed test suite(s) had failures"
    exit 1
fi
