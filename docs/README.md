# Documentation

Welcome to the Omarchy Dotfiles documentation! This directory contains all documentation organized by topic.

## Documentation Index

### Getting Started

- **[Installation](../README.md#quick-start)** - Quick start guide in the main README
- **[Prerequisites](#prerequisites)** - What you need before installing
- **[Troubleshooting](#troubleshooting)** - Common issues and fixes

### Reference

- **[Packages](reference/apps.md)** - Available packages and installation
- **[Keybindings](reference/keybindings.md)** - Keyboard shortcuts and aliases

### Contributing

- **[Contributing Guide](contributing/CONTRIBUTING.md)** - Git workflow, commit conventions, how to contribute

---

## Quick Links

### For New Users

1. Start with the main [README](../README.md) in the repository root
2. Run `./install.sh` and follow the prompts
3. Check [Keybindings](reference/keybindings.md) for shortcuts

### For Contributors

1. Read the [Contributing Guide](contributing/CONTRIBUTING.md)
2. Work on the `dev` branch, create PRs to `main`

---

## Prerequisites

Configure 1Password SSH agent for GitHub:

```bash
# ~/.ssh/config
Host github.com
  IdentityAgent ~/.1password/agent.sock
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Permission denied | `chmod +x install.sh` |
| Stow conflicts | Back up existing configs first |
| Failed mid-install | Auto-rollback preserves backups |

---

## Rollback & Uninstall

### Rollback to a previous version

```bash
git checkout v2.0.0 && stow -R omarchy-config
```

### Return to latest

```bash
git checkout main && stow -R omarchy-config
```

### Uninstall

```bash
stow -D omarchy-config   # Remove symlinks
# Backups remain in ~/omarchy-backup-*/
```

---

## Nested Documentation

Context-specific documentation lives alongside the code (progressive disclosure):

- [`omarchy-config/.config/hypr/AGENTS.md`](../omarchy-config/.config/hypr/AGENTS.md) - Hyprland/Hy3 configuration guidance

---

## Documentation Structure

```
docs/
├── README.md                 # This file
├── contributing/
│   └── CONTRIBUTING.md       # Git workflow, conventions
└── reference/
    ├── apps.md               # Package reference
    └── keybindings.md        # Keybindings
```
