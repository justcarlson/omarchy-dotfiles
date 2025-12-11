# Omarchy Dotfiles

Personal dotfiles for Omarchy Linux (Arch + Hyprland). Uses GNU Stow for symlink management.

## Quick Commands

```bash
# Install everything (interactive)
./install.sh

# Stow operations
stow omarchy-config           # Create symlinks
stow -D omarchy-config        # Remove symlinks
stow --adopt omarchy-config   # Adopt existing files into repo

# Check user-installed packages vs Omarchy base
./check-user-packages.sh

# Reload Hyprland config after changes
hyprctl reload
```

## Project Structure

```
.
├── install.sh              # Main installer (packages, Hy3, Claude Code, MCP)
├── omarchy-config/         # Stow package (mirrors ~/)
│   ├── .config/hypr/       # Hyprland + Hy3 tiling config
│   ├── .config/ghostty/    # Terminal config
│   ├── .config/waybar/     # Status bar
│   ├── .local/bin/         # Custom scripts
│   └── .bashrc             # Shell config
├── README-apps.md          # Package reference (what's installed)
└── README-keybindings.md   # Keybindings reference
```

## Key Files

- `install.sh:41-50` - `OPTIONAL_PACKAGES` array for yay packages
- `install.sh:178-190` - `CONFIGS` array for stow paths
- `omarchy-config/.config/hypr/bindings.conf` - Keybindings
- `omarchy-config/.config/hypr/autostart.conf` - Startup apps

## Code Patterns

**Adding a new config:**
```bash
# 1. Mirror the ~ path structure
mkdir -p omarchy-config/.config/newapp/
cp ~/.config/newapp/config.toml omarchy-config/.config/newapp/

# 2. Add to CONFIGS array in install.sh
# 3. Re-stow: stow omarchy-config
```

**Adding a new optional package:**
```bash
# Add to OPTIONAL_PACKAGES in install.sh:
"packagename|Category|Description"

# If it needs post-install setup, add to POST_INSTALL_MAP
```

**Adding a keybinding:**
```bash
# In bindings.conf, format:
bindd = SUPER SHIFT, KEY, Description, exec, command
```

## Git Workflow

- Commit format: conventional commits (`feat:`, `fix:`, `docs:`)
- Push directly to master (personal dotfiles)

## Boundaries

**Always:**
- Place configs in `omarchy-config/` mirroring `~/` structure
- Update `CONFIGS` array when adding new config paths
- Test keybindings with `hyprctl reload` before committing

**Ask first:**
- Adding packages to `OPTIONAL_PACKAGES`
- Modifying `install.sh` logic

**Never:**
- Run `install.sh` with sudo
- Edit files in `~/.local/share/omarchy/` (override in personal configs instead)
- Commit API keys or credentials

## Nested Guidance

- `omarchy-config/.config/hypr/AGENTS.md` - Hyprland/Hy3 specific patterns
