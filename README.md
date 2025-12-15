<p align="center">
  <h1 align="center">Justin's Dotfiles</h1>
  <p align="center">
    <em>Modular dotfiles for Omarchy Linux + Hyprland</em>
  </p>
  <p align="center">
    <a href="https://github.com/basecamp/omarchy"><img src="https://img.shields.io/badge/Omarchy-FF6B6B?style=flat&logo=linux&logoColor=white" alt="Omarchy"></a>
    <img src="https://img.shields.io/badge/Arch_Linux-1793D1?style=flat&logo=arch-linux&logoColor=white" alt="Arch Linux">
    <img src="https://img.shields.io/badge/Hyprland-58E1FF?style=flat&logo=hyprland&logoColor=black" alt="Hyprland">
    <img src="https://img.shields.io/badge/version-2.3.0-blue?style=flat" alt="Version">
    <img src="https://img.shields.io/badge/license-MIT-green?style=flat" alt="License">
  </p>
</p>

<p align="center">
  <a href="#quick-start">Quick Start</a> •
  <a href="#features">Features</a> •
  <a href="#whats-inside">What's Inside</a> •
  <a href="#customize">Customize</a> •
  <a href="README-keybindings.md">Keybindings</a>
</p>

---

## Quick Start

> **📍 You're on the `dev` branch**
> 
> This branch contains the latest development changes. For stable releases, see the [`main`](https://github.com/justcarlson/dotfiles/tree/main) branch.

```bash
git clone git@github.com:justcarlson/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
git checkout dev
./install.sh
```

The installer will guide you through setup with a polished TUI powered by [Gum](https://github.com/charmbracelet/gum).

| Flag | Effect |
|------|--------|
| `--check` | Preview changes (dry run) |
| `--skip-packages` | Skip optional packages |
| `--skip-secrets` | Skip API key setup |

<details>
<summary>Prerequisites</summary>

Configure 1Password SSH agent for GitHub:

```bash
# ~/.ssh/config
Host github.com
  IdentityAgent ~/.1password/agent.sock
```

</details>

<details>
<summary>Troubleshooting</summary>

| Issue | Fix |
|-------|-----|
| Permission denied | `chmod +x install.sh` |
| Stow conflicts | Back up existing configs first |
| Failed mid-install | Auto-rollback preserves backups |

</details>

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
├── lib/
│   ├── tui.sh            # Gum-powered prompts
│   ├── secrets.sh        # API key management
│   └── packages.sh       # Package registry
└── omarchy-config/       # Stow package → ~/
    ├── .config/
    │   ├── hypr/         # Hyprland + Hy3 tiling
    │   ├── waybar/       # Status bar
    │   ├── ghostty/      # Terminal
    │   └── walker/       # App launcher
    ├── .local/bin/       # Scripts
    └── .bashrc           # Shell config
```

### Tech Stack

| Component | Tool |
|-----------|------|
| Window Manager | [Hyprland](https://hyprland.org) + [Hy3](https://github.com/outfoxxed/hy3) |
| Terminal | [Ghostty](https://ghostty.org) |
| Shell | Bash + [Starship](https://starship.rs) |
| Launcher | [Walker](https://github.com/abenz1267/walker) |
| Bar | [Waybar](https://github.com/Alexays/Waybar) |

---

## Customize

After install, edit these files:

| File | Purpose |
|------|---------|
| `~/.config/hypr/bindings.conf` | Keybindings |
| `~/.config/hypr/autostart-opencode.conf` | OpenCode workspaces |
| `~/.config/opencode/opencode.jsonc` | OpenCode MCP config |
| `~/.secrets` | API keys for MCP |

Symlinks mean your edits update the repo automatically.

```bash
cd ~/.dotfiles && git pull   # Sync latest (instant apply)
```

<details>
<summary>Git Workflow</summary>

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full git workflow, commit conventions, and contribution guidelines.

</details>

<details>
<summary>Rollback</summary>

```bash
git checkout v2.0.0 && stow -R omarchy-config   # Previous version
git checkout main && stow -R omarchy-config     # Latest
```

</details>

<details>
<summary>Uninstall</summary>

```bash
stow -D omarchy-config   # Remove symlinks
# Backups remain in ~/omarchy-backup-*/
```

</details>

---

## Documentation

| Doc | Description |
|-----|-------------|
| [Keybindings](README-keybindings.md) | Keyboard shortcuts & aliases |
| [Packages](README-apps.md) | Available optional packages |

---

<p align="center">
  <sub>Built for <a href="https://omarchy.org">Omarchy Linux</a></sub>
</p>
