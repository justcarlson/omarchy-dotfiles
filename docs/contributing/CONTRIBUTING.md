# Contributing to Omarchy Dotfiles

## Development Installation

For working on the `dev` branch:

```bash
git clone https://github.com/justcarlson/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
git checkout dev
./install.sh
```

## Git Workflow

All changes follow this workflow:

1. **Work on `dev` branch** - All changes are committed to `dev`
2. **Create PR to `main`** - Push `dev` and create a pull request
3. **Merge to `main`** - Merge the PR (preserving `dev` branch)
4. **Tag releases** - Apply version tags to `main` after significant changes

### Commands

```bash
# Make changes on dev
git checkout dev
# ... make changes ...
git add -A && git commit -m "message"
git push origin dev

# Create and merge PR
gh pr create --title "Title" --body "Description"
gh pr merge --merge

# Sync main locally
git fetch origin && git checkout main && git pull && git checkout dev

# Tag a release (on main)
git checkout main
git tag -a v1.0.0 -m "Release description"
git push origin v1.0.0
git checkout dev
```

### Branch Rules

- **`dev`** - Development branch, preserved after merges
- **`main`** - Stable branch, receives merges from `dev`
- **Never** push directly to `main`
- **Never** delete `dev` branch after merge

## CI Pipeline

All PRs to `main` must pass CI before merging.

### Jobs

| Job | Purpose |
|-----|---------|
| `shellcheck` | Lint bash scripts (warning severity) |
| `test` | Run `./tests/run_tests.sh` |
| `dry-run` | Run `./install.sh --check` |

### Local Validation

```bash
# Run all checks locally before pushing
shellcheck -S warning -e SC1090 -e SC1091 install.sh lib/*.sh
./tests/run_tests.sh
./install.sh --check --skip-packages --skip-secrets
```

### Branch Protection

`main` is protected:
- PRs required (no direct pushes)
- All CI jobs must pass
- Enforced for administrators

See `.github/AGENTS.md` for CI implementation details.

## Commit Messages

Use clear, descriptive commit messages:

- `Add <feature>` - New functionality
- `Fix <issue>` - Bug fixes
- `Update <component>` - Enhancements to existing features
- `Remove <item>` - Deletions
- `docs: <description>` - Documentation-only changes
- `chore: <description>` - Maintenance tasks

## Adding New Packages

1. Add entry to `PACKAGE_REGISTRY` in `lib/packages.sh`
2. Format: `"name|category|description|config_files|autostart_entry|post_install"`
3. See existing entries for examples

## Adding New Configs

1. Place file at mirror path in `omarchy-config/` (e.g., `~/.config/foo` → `omarchy-config/.config/foo`)
2. Add path to `CONFIGS` array in `install.sh` for backup handling
3. Run `stow omarchy-config` to create symlinks

## Excluding Paths from Stow

Add patterns to `omarchy-config/.stow-local-ignore`:

```
# Regex patterns for paths to exclude
\.config/AppName
```

Use this for apps that mix runtime files with config (like Cursor).

## Version Tagging

- **Major** (v2.0.0) - Breaking changes
- **Minor** (v2.1.0) - New features, backward compatible
- **Patch** (v2.1.1) - Bug fixes, documentation updates
