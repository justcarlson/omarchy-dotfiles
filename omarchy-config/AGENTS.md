---
parent: [AGENTS.md](../AGENTS.md)
children:
  - [AGENTS.md](.config/hypr/AGENTS.md)
---

# Omarchy Config (Stow Package)

Stow package mirroring `~/` structure. Run `stow omarchy-config` to symlink all configs to home directory.

## Stow Mechanics

- Files here create symlinks at corresponding `~/` paths
- Directory structure must exactly mirror `~/`
- Use `.stow-local-ignore` to exclude files from symlinking

## App Configs

### Ghostty (`.config/ghostty/`)

Terminal emulator. Theme dynamically linked from `~/.config/omarchy/current/theme/ghostty.conf` using conditional include (`?=`). Key settings: CaskaydiaMono Nerd Font @ 11pt, block cursor, custom keybinds.

### Waybar (`.config/waybar/`)

Status bar. `config.jsonc` defines modules: workspaces, clock, network, battery, bluetooth, pulseaudio, cpu, system tray. `style.css` handles theming. Modules call `omarchy-*` scripts for actions.

### Walker (`.config/walker/`)

App launcher with prefix-based providers:
- `/` provider list | `.` files | `:` symbols | `=` calc | `@` websearch | `$` clipboard

Theme loaded from `~/.local/share/omarchy/default/walker/themes/`.

### OpenCode (`.config/opencode/`)

OpenCode CLI configuration.

### Starship (`.config/starship.toml`)

Shell prompt configuration.

### UWSM (`.config/uwsm/`)

Session manager environment variables.

## Custom Scripts (`.local/bin/`)

| Script | Purpose |
|--------|---------|
| `omarchy-launch-browser` | Launch default browser with correct private flag (Firefox/Zen vs Chrome) |
| `setup-claude-code-statusline.sh` | Install ccstatusline + configure Claude Code status bar with git info |

## Boundaries

- **Always:** Mirror `~/` structure exactly
- **Always:** Use conditional includes (`?=` in ghostty) for optional dependencies
- **Always:** Test with `stow -n omarchy-config` (dry run) before applying
- **Never:** Put machine-specific configs here (use `~/.config/local/` overrides)
- **Never:** Include secrets or API keys

## Adding New Configs

```bash
# 1. Create directory mirroring ~/
mkdir -p omarchy-config/.config/newapp/

# 2. Copy config
cp ~/.config/newapp/config.toml omarchy-config/.config/newapp/

# 3. Test symlink
stow -n omarchy-config

# 4. Apply
stow omarchy-config
```
