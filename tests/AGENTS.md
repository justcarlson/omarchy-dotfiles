---
parent: [AGENTS.md](../AGENTS.md)
---

# Tests

Test suite for lib/ functions.

## Commands

```bash
./tests/run_tests.sh          # Run all tests
./tests/test_tui.sh           # Run single test file
```

## Adding Tests

1. Create `tests/test_<name>.sh`
2. Use assert helpers from `test_tui.sh`: `assert_eq`, `assert_empty`, `assert_not_empty`, `assert_exit_code`
3. Source the library under test: `source "$REPO_DIR/lib/<name>.sh"`
4. Exit with `$FAILED` count

## Boundaries

- **Always:** Run `./tests/run_tests.sh` before committing
- **Always:** Use existing assert helpers
- **Always:** Use `timeout` for commands that might hang
