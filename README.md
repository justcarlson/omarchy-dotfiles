# Omarchy Dotfiles

Personal dotfiles for [Omarchy Linux](https://omarchy.com) — Arch + Hyprland on Apple T2 MacBooks.

```
┌─────────────────────────────────────────────────────────────┐
│  Hyprland + Hy3  │  Ghostty  │  Starship  │  GNU Stow      │
└─────────────────────────────────────────────────────────────┘
```

<details>
<summary>Prerequisites (1Password SSH)</summary>

Configure 1Password SSH agent for GitHub authentication:

1. 1Password → Settings → Developer → Enable "Use the SSH agent"
2. Add your GitHub SSH key to 1Password
3. Add to `~/.ssh/config`:
   ```
   Host github.com
     IdentityAgent ~/.1password/agent.sock
   ```

</details>

## Quick Start

```bash
git clone git@github.com:justcarlson/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The installer will:
- ✓ Back up existing configs
- ✓ Create symlinks via GNU Stow
- ✓ Offer Hy3 plugin & Claude Code
- ✓ Let you pick optional packages
- ✓ Configure API keys for MCP

**Options:**
| Flag | Effect |
|------|--------|
| `--check` | Dry run — preview without changes |
| `--skip-packages` | Skip optional package selection |
| `--skip-secrets` | Skip API key configuration |

> No `sudo` needed — the script runs as your user.

<details>
<summary>Stow Conflicts</summary>

If you see "cannot stow" errors, back up existing configs first:

```bash
mkdir -p ~/omarchy-backup-manual
mv ~/.config/hypr ~/.config/waybar ~/.config/walker \
   ~/.config/ghostty ~/.config/uwsm ~/.config/starship.toml \
   ~/.bashrc ~/.XCompose ~/omarchy-backup-manual/
./install.sh
```

Or adopt existing configs into the repo: `stow --adopt omarchy-config`

</details>

<details>
<summary>Troubleshooting</summary>

| Problem | Solution |
|---------|----------|
| Permission denied | `chmod +x install.sh` |
| Command not found (sudo) | Don't use sudo |
| Stow conflicts | See above |
| Install failed mid-way | Auto-rollback preserves `~/omarchy-backup-*/` |

</details>

---

## What's Inside

```
~/.dotfiles/
├── install.sh           # Interactive installer
├── lib/
│   ├── tui.sh           # Gum-powered UI
│   ├── secrets.sh       # ~/.secrets management
│   └── packages.sh      # Package registry
└── omarchy-config/      # Stow package → ~/
    ├── .config/hypr/    # Hyprland + Hy3
    ├── .config/ghostty/ # Terminal
    ├── .config/waybar/  # Status bar
    └── .bashrc          # Shell
```

## Customize

Edit these after install:

| File | Purpose |
|------|---------|
| `~/.config/hypr/bindings.conf` | Keybindings |
| `~/.config/hypr/autostart-claude.conf` | Claude Code workspaces |
| `~/.secrets` | API keys (MCP integrations) |

## Update

Symlinks mean edits in `~/.config/` update the repo automatically.

```bash
cd ~/.dotfiles && git pull   # Changes apply immediately
```

<details>
<summary>Git Workflow</summary>

```bash
# Feature branch
git checkout -b feature/thing
# ... make changes in ~/.config/ ...
git add -A && git commit -m "feat: thing"
git push -u origin feature/thing
gh pr create --fill

# After merge
git checkout main && git pull
git branch -d feature/thing
```

</details>

<details>
<summary>Rollback</summary>

```bash
git checkout v2.0.0 && stow -R omarchy-config   # Roll back
git checkout main && stow -R omarchy-config     # Return to latest
```

**Versions:** v2.0.0 (modular TUI) · v1.0.0 (initial release)

</details>

<details>
<summary>Uninstall</summary>

```bash
stow -D omarchy-config   # Remove symlinks
```

Backups remain in `~/omarchy-backup-*/`

</details>

---

**Docs:** [Keybindings](README-keybindings.md) · [Packages](README-apps.md)
