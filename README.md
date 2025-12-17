<p align="center">
  <h1 align="center">Justin's Dotfiles</h1>
  <p align="center">
    <em>Modular dotfiles for Omarchy Linux + Hyprland</em>
  </p>
  <p align="center">
    <a href="https://github.com/basecamp/omarchy"><img src="https://img.shields.io/badge/Omarchy-FF6B6B?style=flat&logo=linux&logoColor=white" alt="Omarchy"></a>
    <img src="https://img.shields.io/badge/Arch_Linux-1793D1?style=flat&logo=arch-linux&logoColor=white" alt="Arch Linux">
    <img src="https://img.shields.io/badge/Hyprland-58E1FF?style=flat&logo=hyprland&logoColor=black" alt="Hyprland">
    <a href="https://github.com/justcarlson/dotfiles/releases"><img src="https://img.shields.io/github/v/release/justcarlson/dotfiles?style=flat&label=version&color=blue" alt="Version"></a>
    <!-- <img src="https://img.shields.io/badge/license-MIT-green?style=flat" alt="License"> ## no MIT license, presently--> 
    <a href="docs/contributing/CONTRIBUTING.md"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs Welcome"></a>
    <a href="https://github.com/justcarlson/dotfiles/actions/workflows/ci.yml"><img src="https://github.com/justcarlson/dotfiles/actions/workflows/ci.yml/badge.svg?branch=dev" alt="CI"></a>
  </p>
</p>

<p align="center">
  <a href="#quick-start">Quick Start</a> •
  <a href="#features">Features</a> •
  <a href="#whats-inside">What's Inside</a> •
  <a href="docs/README.md">Docs</a>
</p>

---

## Quick Start

```bash
git clone git@github.com:justcarlson/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The installer guides you through setup with a polished TUI powered by [Gum](https://github.com/charmbracelet/gum).

| Flag | Effect |
|------|--------|
| `--check` | Preview changes (dry run) |
| `--skip-packages` | Skip optional packages |
| `--skip-secrets` | Skip API key setup |

---

## Features

- **Gum-powered TUI** — Beautiful prompts with graceful fallbacks
- **GNU Stow** — Symlink management, edit configs in place
- **Package Registry** — Single source of truth for optional apps
- **Secrets Management** — `~/.secrets` for API keys (never committed)
- **Idempotent** — Safe to run multiple times
- **Auto-rollback** — Restores backups if something fails

---

## What's Inside

```
~/.dotfiles/
├── install.sh            # Interactive installer
├── lib/                  # Modular libraries
├── docs/                 # Documentation
└── omarchy-config/       # Stow package → ~/
    ├── .config/
    │   ├── hypr/         # Hyprland + Hy3 tiling
    │   ├── waybar/       # Status bar
    │   ├── ghostty/      # Terminal
    │   └── walker/       # App launcher
    ├── .local/bin/       # Scripts
    └── .bashrc           # Shell config
```

---

## Documentation

| Doc | Description |
|-----|-------------|
| [Docs Index](docs/README.md) | Full documentation |
| [Keybindings](docs/reference/keybindings.md) | Keyboard shortcuts |
| [Packages](docs/reference/apps.md) | Available packages |
| [Contributing](docs/contributing/CONTRIBUTING.md) | Git workflow |

---

<p align="center">
  <sub>Built for <a href="https://omarchy.org">Omarchy Linux</a></sub>
</p>
