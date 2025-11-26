# Omarchy Dotfiles

Justin's dotfiles and configuration for Omarchy Linux (Arch-based with Hyprland).

## Prerequisites

This repo requires SSH authentication. Configure 1Password SSH agent first:

1. Open 1Password > Settings > Developer
2. Enable "Use the SSH agent"
3. Add your GitHub SSH key to 1Password
4. Create/update `~/.ssh/config`:
   ```
   Host github.com
     IdentityAgent ~/.1password/agent.sock
   ```

## Quick Start

### Fresh Omarchy Installation

1. **Clone this repository:**
   ```bash
   git clone git@github.com:justcarlson/omarchy-dotfiles.git ~/dotfiles
   ```

2. **Run the installer:**
   ```bash
   cd ~/dotfiles
   chmod +x install.sh
   ./install.sh
   ```

   The script will:
   - Back up existing configs to `~/omarchy-backup-TIMESTAMP/`
   - Install GNU Stow if needed
   - Create symlinks to your dotfiles
   - Offer to install 3 additional apps (VSCode, Chrome Beta, Solaar)

   **Important:** Do NOT use `sudo` - the script doesn't need it.

### If You Get Conflicts

If the install script fails with "cannot stow" errors, you have existing configs that need to be moved first:

**Option 1: Manual backup** (recommended for clean install)
```bash
# Backup your current configs
mkdir -p ~/omarchy-backup-manual
mv ~/.config/hypr ~/omarchy-backup-manual/
mv ~/.config/waybar ~/omarchy-backup-manual/
mv ~/.config/walker ~/omarchy-backup-manual/
mv ~/.config/ghostty ~/omarchy-backup-manual/
mv ~/.config/uwsm ~/omarchy-backup-manual/
mv ~/.config/starship.toml ~/omarchy-backup-manual/
mv ~/.bashrc ~/omarchy-backup-manual/
mv ~/.XCompose ~/omarchy-backup-manual/

# Run the install script
./install.sh
```

**Option 2: Adopt existing configs** (merges your current configs into the repo)
```bash
cd ~/dotfiles
stow --adopt omarchy-config
```

## What's Included

- **`omarchy-config/`** - Dotfiles for Hyprland, Waybar, Ghostty, Walker, uwsm, etc.
- **`install.sh`** - Backup, stow, and optional app installation
- **`README-apps.md`** - Reference list of packages

### Configured Applications

- **Hyprland** - Window manager
- **Waybar** - Top bar
- **Walker** - Launcher
- **Ghostty** - Terminal
- **uwsm** - Session manager
- **Starship** - Shell prompt
- **.bashrc and .XCompose** - Shell and input configs

## Documentation

- **[Package Reference](README-apps.md)** - List of optional and pre-installed packages
- All configs are managed with [GNU Stow](https://www.gnu.org/software/stow/)

## Updating Configs

### Save your local changes to the repo:
```bash
cd ~/dotfiles
git add -A
git commit -m "Update configs"
git push
```

Since Stow creates symlinks, editing files in `~/.config/` automatically updates the files in `~/dotfiles/`.

### Pull latest configs from the repo:
```bash
cd ~/dotfiles
git pull
```

Changes are immediately active since the files are symlinked.

## Uninstalling

To remove the symlinks and restore your configs to regular files:
```bash
cd ~/dotfiles
stow -D omarchy-config
```

Your backup configs will still be in `~/omarchy-backup-*/` if you need them.

## Notes

- **Never run install scripts with `sudo`** - they don't need it
- Uses GNU Stow for symlink management
- Designed for Omarchy Linux (Arch-based, Hyprland WM)
- Optimized for Apple T2 MacBooks

## Troubleshooting

**"Permission denied" when running scripts:**
```bash
chmod +x install.sh
```

**"command not found" with sudo:**
Don't use sudo. Run scripts as your regular user.

**Stow conflicts:**
See "If You Get Conflicts" section above.
