# Package Reference

Packages referenced in the dotfiles configuration.

## Optional (Not Pre-installed on Omarchy)

These are offered during `./install.sh`:

| Package | Purpose | Config Reference |
|---------|---------|------------------|
| visual-studio-code-bin | Code editor | `EDITOR=code` in uwsm/default |
| google-chrome-beta | Web browser | `BROWSER` in uwsm/default |
| tailscale | Mesh VPN | Remote access |
| solaar | Logitech device manager | For MX mice/keyboards |
| python-pipx | Isolated Python apps | Required for PyGPT |

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
| nautilus | File manager | Super+Shift+F |

## Installed via pipx

These are offered during `./install.sh` after the yay packages:

| Package | Purpose | Install Command |
|---------|---------|-----------------|
| pygpt-net | PyGPT AI assistant | `pipx install pygpt-net` |

## Manual Installation

To install any package individually:
```bash
yay -S <package-name>
```
