---
parent: [AGENTS.md](../AGENTS.md)
---

# lib/ - Bash Libraries

Modular bash libraries for the install system.

## Sourcing Order

```bash
source lib/tui.sh       # Must be first (no dependencies)
source lib/packages.sh  # Requires tui.sh
source lib/secrets.sh   # Requires tui.sh
```

## Boundaries

- **Always:** Source `tui.sh` before other libs
- **Always:** Use existing `tui_*` functions for user interaction
- **Always:** Run `./tests/run_tests.sh` after changes
- **Never:** Add external dependencies without updating install.sh
- **Never:** Echo directly to stdout; use `tui_*` functions

## Reference

Read source files for function signatures and usage patterns.
