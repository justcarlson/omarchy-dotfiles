# Package Reference

Packages referenced in the dotfiles configuration.

## Optional (Not Pre-installed on Omarchy)

These are offered during `./install.sh`:

| Package | Purpose | Config Reference |
|---------|---------|------------------|
| google-chrome-beta | Web browser | `BROWSER` in uwsm/default |
| tailscale | Mesh VPN | Remote access |
| solaar | Logitech device manager | For MX mice/keyboards |
| tree | Directory tree viewer | CLI |
| bun-bin | JavaScript runtime | CLI |
| wev | Wayland event viewer | Debugging keybindings |
| wget | Network file downloader | CLI |
| cursor-bin | AI-first coding environment | Super+Shift+I |

## Pre-installed on Omarchy

These are included in Omarchy's base packages and referenced in bindings.conf:

| Package | Purpose | Keybinding |
|---------|---------|------------|
| btop | System monitor | Super+Shift+T |
| lazydocker | Docker TUI | Super+Shift+D |
| obsidian | Note-taking | Super+Shift+O |
| typora | Markdown editor | Super+Shift+W |
| signal-desktop | Encrypted messaging | Super+Shift+G |
| spotify | Music streaming | Super+Shift+M |
| ripgrep | Fast text search | CLI |
| ghostty | Terminal | TERMINAL env |
| 1password-beta | Password manager | Super+Shift+/ |
| nautilus | GUI file manager | Super+Shift+F |

## CLI Coding Agents

Installed during `./install.sh`:

| Package | Purpose | Install Command |
|---------|---------|-----------------|
| [OpenCode](https://github.com/sst/opencode) | Primary CLI agent (open source) | `curl -fsSL https://opencode.ai/install \| bash` |
| [Claude Code](https://github.com/anthropics/claude-code) | Fallback CLI agent (Anthropic) | `npm i -g @anthropic-ai/claude-code` |

## Development Tools

| Package | Purpose | Install | Keybinding |
|---------|---------|---------|------------|
| cursor-bin | AI-first coding environment | `yay -S cursor-bin` | Super+Shift+I |

Cursor is installed from the Omarchy repo. Updates come via `yay -Syu`.

To suppress update notifications, add to `~/.config/Cursor/User/settings.json`:
```json
{
  "update.mode": "none",
  "update.showReleaseNotes": false,
  "extensions.autoCheckUpdates": false,
  "extensions.autoUpdate": false
}
```

> **Note:** Cursor's config directory contains runtime files mixed with settings, so it's not managed by stow. Apply settings manually or copy from the snippet above.

## Manual Installation (yay)

To install any package individually:
```bash
yay -S <package-name>
```
