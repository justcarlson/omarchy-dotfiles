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

All changes follow this automated workflow:

1. **Work on `dev` branch** - Commit changes using Conventional Commits
2. **Create PR to `main`** - CI validates, requires passing checks
3. **Merge to `main`** - Release Please auto-creates a Release PR
4. **Merge Release PR** - Auto-creates git tag and GitHub Release

### Conventional Commits

All commits must follow the [Conventional Commits](https://conventionalcommits.org) format:

| Prefix | Version Bump | Example |
|--------|--------------|---------|
| `feat:` | Minor (3.4.0 → 3.5.0) | `feat: add waybar weather module` |
| `fix:` | Patch (3.4.0 → 3.4.1) | `fix: correct hyprland monitor config` |
| `feat!:` | Major (3.4.0 → 4.0.0) | `feat!: restructure config directory` |
| `docs:` | No release | `docs: update keybindings reference` |
| `chore:` | No release | `chore: update CI workflow` |
| `refactor:` | No release | `refactor: simplify install.sh logic` |
| `perf:` | Patch | `perf: optimize startup time` |
| `test:` | No release | `test: add install.sh tests` |
| `ci:` | No release | `ci: update GitHub Actions` |

### Commands

```bash
# Make changes on dev
git checkout dev
# ... make changes ...
git add -A && git commit -m "feat: add new feature"
git push origin dev

# Create PR to main
gh pr create --title "feat: add new feature" --body "Description"

# After PR merges:
# - Release Please auto-creates a Release PR
# - Merge the Release PR to create a new version tag
```

### What Gets Automated

| Task | Automated By |
|------|--------------|
| Version bump decision | Release Please (from commit prefixes) |
| CHANGELOG.md updates | Release Please |
| README version badge | Release Please |
| Git tag creation | Release Please |
| GitHub Release | Release Please |
| Empty PR prevention | CI (block-empty-prs workflow) |

### Branch Rules

- **`dev`** - Development branch, all work happens here
- **`main`** - Stable branch, always safe to clone
- **Never** push directly to `main` or `dev` (use PRs)
- **Never** delete `dev` branch
- **Never** force push to `dev` or `main`
- **Rarely** need to sync `dev` with `main` (only if `main` has hotfixes that `dev` lacks)

### Rollback

If a bad config is merged to `main`:

1. **From GitHub**: Revert the PR (creates a revert commit)
2. **Or checkout a previous tag**: `git clone --branch v3.4.0 ...`

## CI Pipeline

All PRs must pass CI before merging.

### Jobs

| Job | Purpose |
|-----|---------|
| `shellcheck` | Lint bash scripts (warning severity) |
| `test` | Run `./tests/run_tests.sh` |
| `dry-run` | Run `./install.sh --check` |
| `check-changes` | Block PRs with 0 file changes |

### Local Validation

```bash
# Run all checks locally before pushing
shellcheck -S warning -e SC1090 -e SC1091 install.sh lib/*.sh
./tests/run_tests.sh
./install.sh --check --skip-packages --skip-secrets
```

### Branch Protection

Both `main` and `dev` are protected:
- PRs required (no direct pushes)
- All CI jobs must pass
- Enforced for administrators

See `.github/AGENTS.md` for CI implementation details.

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

Versioning is fully automated by Release Please:

- **Major** (v2.0.0) - Breaking changes (`feat!:` or `fix!:`)
- **Minor** (v2.1.0) - New features (`feat:`)
- **Patch** (v2.1.1) - Bug fixes (`fix:`, `perf:`)

The Release PR updates:
- `version.txt`
- `CHANGELOG.md`
- README.md version badge

Simply merge the Release PR to create the release.
