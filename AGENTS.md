---
children:
  - [AGENTS.md](.github/AGENTS.md)
  - [AGENTS.md](lib/AGENTS.md)
  - [AGENTS.md](tests/AGENTS.md)
  - [AGENTS.md](docs/AGENTS.md)
  - [AGENTS.md](omarchy-config/AGENTS.md)
---

# Omarchy Dotfiles

Personal dotfiles for Omarchy Linux (Arch + Hyprland). Uses GNU Stow for symlink management.

## Tech Stack

- **OS:** Omarchy Linux (Arch-based) on Apple T2 MacBooks
- **WM:** Hyprland + Hy3 plugin | **Terminal:** Ghostty | **Shell:** Bash + Starship
- **Packages:** yay (AUR) | **TUI:** Gum

## Commands

```bash
./install.sh                  # Interactive install
./install.sh --check          # Dry run
./tests/run_tests.sh          # Run tests
stow omarchy-config           # Create symlinks
stow -D omarchy-config        # Remove symlinks
```

## Git Workflow

`feature-branch` → PR → `main` → Release Please auto-tags

- Use [Conventional Commits](https://conventionalcommits.org): `feat:`, `fix:`, `docs:`, `chore:`
- Create feature branches from `main`, PR back to `main`
- Version badge, CHANGELOG, and tags are automated by Release Please
- CI runs on all PRs to `main`
- Never force push to `main`
- See [CONTRIBUTING.md](docs/contributing/CONTRIBUTING.md) for details

## Project Structure

```
install.sh              → Main installer
lib/                    → tui.sh, secrets.sh, packages.sh
tests/                  → Test suite
.github/workflows/      → CI/CD
docs/                   → Documentation
omarchy-config/         → Stow package (mirrors ~/)
```

## Boundaries

- **Always:** Place configs in `omarchy-config/` mirroring `~/` structure
- **Always:** Add packages to `PACKAGE_REGISTRY` in `lib/packages.sh`
- **Always:** Store secrets in `~/.secrets`, never in tracked files
- **Never:** Run `install.sh` with sudo
- **Never:** Commit API keys or secrets

## Patterns

**Adding a package:**
```bash
# Add to PACKAGE_REGISTRY in lib/packages.sh
"newpkg|Category|Description|none|exec-once = newpkg|none"
```

**Adding a config:**
```bash
mkdir -p omarchy-config/.config/newapp/
cp ~/.config/newapp/config.toml omarchy-config/.config/newapp/
stow omarchy-config
```

**Adding a secret:**
```bash
echo 'export NEW_API_KEY="xxx"' >> ~/.secrets && chmod 600 ~/.secrets
# Reference via env var: {env:NEW_API_KEY}
```

## Contributing

See [CONTRIBUTING.md](docs/contributing/CONTRIBUTING.md) for git workflow and conventions.

## Issue Tracking with bd (beads)

**IMPORTANT**: This project uses **bd (beads)** for ALL issue tracking. Do NOT use markdown TODOs, task lists, or other tracking methods.

### Why bd?

- Dependency-aware: Track blockers and relationships between issues
- Git-friendly: Auto-syncs to JSONL for version control
- Agent-optimized: JSON output, ready work detection, discovered-from links
- Prevents duplicate tracking systems and confusion

### Quick Start

**Check for ready work:**
```bash
bd ready --json
```

**Create new issues:**
```bash
bd create "Issue title" -t bug|feature|task -p 0-4 --json
bd create "Issue title" -p 1 --deps discovered-from:dotfiles-123 --json
bd create "Subtask" --parent <epic-id> --json  # Hierarchical subtask (gets ID like epic-id.1)
```

**Claim and update:**
```bash
bd update dotfiles-42 --status in_progress --json
bd update dotfiles-42 --priority 1 --json
```

**Complete work:**
```bash
bd close dotfiles-42 --reason "Completed" --json
```

### Issue Types

- `bug` - Something broken
- `feature` - New functionality
- `task` - Work item (tests, docs, refactoring)
- `epic` - Large feature with subtasks
- `chore` - Maintenance (dependencies, tooling)

### Priorities

- `0` - Critical (security, data loss, broken builds)
- `1` - High (major features, important bugs)
- `2` - Medium (default, nice-to-have)
- `3` - Low (polish, optimization)
- `4` - Backlog (future ideas)

### Workflow for AI Agents

1. **Check ready work**: `bd ready` shows unblocked issues
2. **Claim your task**: `bd update <id> --status in_progress`
3. **Work on it**: Implement, test, document
4. **Discover new work?** Create linked issue:
   - `bd create "Found bug" -p 1 --deps discovered-from:<parent-id>`
5. **Complete**: `bd close <id> --reason "Done"`
6. **Commit together**: Always commit the `.beads/issues.jsonl` file together with the code changes so issue state stays in sync with code state

### Writing Self-Contained Issues

Issues must be fully self-contained - readable without any external context (plans, chat history, etc.). A future session should understand the issue completely from its description alone.

**Required elements:**
- **Summary**: What and why in 1-2 sentences
- **Files to modify**: Exact paths (with line numbers if relevant)
- **Implementation steps**: Numbered, specific actions
- **Example**: Show before → after transformation when applicable

**Optional but helpful:**
- Edge cases or gotchas to watch for
- Test references (point to test files or test_data examples)
- Dependencies on other issues

**Bad example:**
```
Implement the refactoring from the plan
```

**Good example:**
```
Add timeout parameter to fetchUser() in src/api/users.ts

1. Add optional timeout param (default 5000ms)
2. Pass to underlying fetch() call
3. Update tests in src/api/users.test.ts

Example: fetchUser(id) → fetchUser(id, { timeout: 3000 })
Depends on: dotfiles-123 (fetch wrapper refactor)
```

### Dependencies: Think "Needs", Not "Before"

`bd dep add X Y` = "X needs Y" = Y blocks X

**TRAP**: Temporal words ("Phase 1", "before", "first") invert your thinking!
```
WRONG: "Phase 1 before Phase 2" → bd dep add phase1 phase2
RIGHT: "Phase 2 needs Phase 1" → bd dep add phase2 phase1
```
**Verify**: `bd blocked` - tasks blocked by prerequisites, not dependents.

### Auto-Sync

bd automatically syncs with git:
- Exports to `.beads/issues.jsonl` after changes (5s debounce)
- Imports from JSONL when newer (e.g., after `git pull`)
- No manual export/import needed!

### CLI Help

Run `bd <command> --help` to see all available flags for any command.
For example: `bd create --help` shows `--parent`, `--deps`, `--assignee`, etc.

### Important Rules

- ✅ Use bd for ALL task tracking
- ✅ Always use `--json` flag for programmatic use
- ✅ Link discovered work with `discovered-from` dependencies
- ✅ Check `bd ready` before asking "what should I work on?"
- ✅ Run `bd <cmd> --help` to discover available flags
- ❌ Do NOT create markdown TODO lists
- ❌ Do NOT use external issue trackers
- ❌ Do NOT duplicate tracking systems

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
