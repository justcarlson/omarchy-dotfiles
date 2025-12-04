# Omarchy Dotfiles

Personal dotfiles repository for Omarchy Linux (Arch-based with Hyprland window manager). Uses GNU Stow for symlink-based configuration management.

## Core Commands

- Install dotfiles: `./install.sh`
- Check for user-installed packages: `./check-user-packages.sh`
- Manually stow configs: `stow omarchy-config`
- Unstow configs: `stow -D omarchy-config`
- Adopt existing configs: `stow --adopt omarchy-config`

## Project Layout

```
├── install.sh              → Main installer script
├── check-user-packages.sh  → Package audit utility
├── omarchy-config/         → Stow package (mirrors ~/)
│   ├── .config/
│   │   ├── hypr/           → Hyprland window manager
│   │   ├── waybar/         → Status bar
│   │   ├── ghostty/        → Terminal emulator
│   │   ├── walker/         → Application launcher
│   │   ├── uwsm/           → Session manager (EDITOR, BROWSER)
│   │   └── starship.toml   → Shell prompt theme
│   ├── .bashrc             → Bash configuration
│   └── .XCompose           → Custom keyboard input
└── README-apps.md          → Package reference
```

## Development Patterns & Constraints

Stow structure
- All dotfiles live in `omarchy-config/` mirroring the home directory structure
- Running `stow omarchy-config` creates symlinks from `~/` into the repo
- Editing `~/.config/*` directly edits repo files (they're symlinks)

Script conventions
- Bash scripts with `set -e` for fail-fast behavior
- No `sudo` required - scripts run as regular user
- Use `yay` for AUR package installation
- Interactive prompts with sensible defaults

Adding new configs
- Place files in `omarchy-config/` at their relative path from `~/`
- Example: `~/.config/foo/bar.conf` → `omarchy-config/.config/foo/bar.conf`
- Update `CONFIGS` array in `install.sh` for backup handling

## Git Workflow

1. Configs auto-update in repo when edited via symlinks
2. Commit with descriptive messages: `git commit -m "Update hyprland bindings"`
3. Pull updates: `git pull` (changes apply immediately via symlinks)

## Gotchas

- Never run `install.sh` with `sudo` - it doesn't need elevated privileges
- Stow conflicts mean existing non-symlink configs exist; back them up first
- The installer comments out autostart entries for apps you skip installing
- Target system is Omarchy Linux on Apple T2 MacBooks
