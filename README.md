# Omarchy Dotfiles

Justin's dotfiles and configuration for Omarchy Linux (Arch-based with Hyprland).

## Quick Start

### Fresh Omarchy Installation

1. **Clone this repository:**
```bash
   git clone https://github.com/justcarlson/omarchy-dotfiles.git ~/dotfiles
   cd ~/dotfiles
```

2. **Install apps:** (Optional but recommended)
```bash
   chmod +x install-my-apps.sh
   ./install-my-apps.sh
```
   See [README-apps.md](README-apps.md) for details on the 171+ packages included.

3. **Restore dotfiles with Stow:**
```bash
   stow omarchy-config
```

## What's Included

- **`omarchy-config/`** - Dotfiles for Hyprland, Waybar, Ghostty, Alacritty, etc.
- **`install-my-apps.sh`** - Automated installation of 171 packages organized by category
- **`install.sh`** - Original installation script

## Documentation

- **[App Installation Guide](README-apps.md)** - Details on automated package installation
- All configs are managed with [GNU Stow](https://www.gnu.org/software/stow/)

## Updating

### Backup new configs to this repo:
```bash
cd ~/dotfiles
# Stow automatically links files, so just commit changes:
git add -A
git commit -m "Update configs"
git push
```

### Pull latest configs:
```bash
cd ~/dotfiles
git pull
# Stow will automatically use updated files
```

## Notes

- Uses GNU Stow for symlink management
- Designed for Omarchy Linux (Arch-based, Hyprland WM)
- Optimized for Apple T2 MacBooks
