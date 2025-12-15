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

`dev` → PR → `main` → version tag

- Commit to `dev`, PR to `main`, tag releases on `main`
- Include version badge update in PR (before merge, not after)
- CI runs on push to `dev` and PRs to `main`
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
