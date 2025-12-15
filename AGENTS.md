# Omarchy Dotfiles

Personal dotfiles for Omarchy Linux (Arch + Hyprland). Uses GNU Stow for symlink management.

## Tech Stack

- **OS:** Omarchy Linux (Arch-based) on Apple T2 MacBooks
- **WM:** Hyprland with Hy3 plugin (i3-like tiling)
- **Terminal:** Ghostty
- **Shell:** Bash + Starship prompt
- **Package Manager:** yay (AUR)
- **TUI:** Gum for styled prompts

## Commands

```bash
# Install everything (interactive)
./install.sh

# Install with options
./install.sh --check          # Dry run - preview changes
./install.sh --skip-packages  # Skip optional package selection
./install.sh --skip-secrets   # Skip API key configuration
./install.sh --debug          # Enable debug output for troubleshooting

# Run tests
./tests/run_tests.sh          # Run automated test suite

# Stow operations
stow omarchy-config           # Create symlinks
stow -D omarchy-config        # Remove symlinks
stow --adopt omarchy-config   # Adopt existing configs
```

## Project Structure

```
├── install.sh              → Main installer (orchestrator)
├── lib/                    → Modular libraries
│   ├── tui.sh              → Gum wrappers for styled UI
│   ├── secrets.sh          → ~/.secrets management
│   └── packages.sh         → Package registry & installer
├── docs/                   → Documentation
│   ├── README.md           → Docs index
│   ├── contributing/       → Contribution guidelines
│   └── reference/          → Packages & keybindings
├── omarchy-config/         → Stow package (mirrors ~/)
│   ├── .config/hypr/       → Hyprland + Hy3 config
│   ├── .config/ghostty/    → Terminal config
│   ├── .local/bin/         → Scripts
│   └── .bashrc             → Shell config
```

## Boundaries

- ✅ **Always:** Place new configs in `omarchy-config/` mirroring `~/` structure
- ✅ **Always:** Update `CONFIGS` array in `install.sh` when adding new config paths
- ✅ **Always:** Add new packages to `PACKAGE_REGISTRY` in `lib/packages.sh`
- ✅ **Always:** Store secrets in `~/.secrets`, never in tracked files
- ⚠️ **Ask first:** Adding new package dependencies
- 🚫 **Never:** Run `install.sh` with `sudo` - it doesn't need elevated privileges
- 🚫 **Never:** Edit `~/.local/share/omarchy/` files - override in personal configs
- 🚫 **Never:** Commit API keys or secrets to git

## Contributing

See [CONTRIBUTING.md](docs/contributing/CONTRIBUTING.md) for the required git workflow, commit conventions, and contribution guidelines.

## Patterns

**Adding a new package:**
```bash
# 1. Add to PACKAGE_REGISTRY in lib/packages.sh
# Format: "name|category|description|config_files|autostart_entry|post_install"
"newpkg|Category|Description|none|exec-once = newpkg|none"

# 2. That's it! The install script will handle the rest.
```

**Adding a new config:**
```bash
# 1. Place file at mirror path
mkdir -p omarchy-config/.config/newapp/
cp ~/.config/newapp/config.toml omarchy-config/.config/newapp/

# 2. Re-stow
stow omarchy-config

# 3. Add to CONFIGS array in install.sh for backup handling
```

**Adding a secret:**
```bash
# Secrets go in ~/.secrets (created by install.sh or manually)
echo 'export NEW_API_KEY="xxx"' >> ~/.secrets
chmod 600 ~/.secrets

# Reference in configs via environment variable
# e.g., in MCP config: {env:NEW_API_KEY}
```

**Adding a guarded keybinding:**
```bash
# In bindings.conf - guards ensure graceful failure if app not installed
bindd = SUPER SHIFT, KEY, Description, exec, command -v app &>/dev/null && uwsm-app -- app || notify-send "app not installed" "Install with: yay -S app"
```

**Stow conflicts:** Existing non-symlink configs must be backed up or removed first.

**Symlink editing:** `~/.config/*` edits go directly to repo files (they're symlinks).

## Library Reference

### lib/tui.sh
Gum wrappers with fallback to basic prompts:
- `tui_header "Title"` - Section header
- `tui_confirm "Question?"` - Yes/no prompt
- `tui_input "Label" "placeholder"` - Text input
- `tui_secret "Label"` - Password input
- `tui_choose "opt1" "opt2"` - Single select
- `tui_choose_multi "header" "opt1" "opt2"` - Multi-select (supports piped input)
- `tui_filter "placeholder"` - Fuzzy filter from piped input
- `tui_spin "Message..." command` - Spinner
- `tui_success/error/warning/info "msg"` - Status messages
- `tui_is_dry_run` - Check if running in dry-run mode
- `tui_exec "desc" command` - Execute only if not dry-run
- `_debug "msg"` - Debug output (enabled by `OMARCHY_DEBUG=1` or `--debug`)

### lib/secrets.sh
Manages `~/.secrets` file:
- `secrets_init` - Create secrets file
- `secrets_get "KEY"` - Get secret value
- `secrets_set "KEY" "value"` - Set secret
- `secrets_prompt "KEY" "Label" "hint"` - Interactive prompt
- `secrets_collect_mcp` - Collect MCP API keys

### lib/packages.sh
Package registry and installation:
- `PACKAGE_REGISTRY` - Array of package definitions
- `pkg_is_installed "name"` - Check if installed
- `pkg_install_many "pkg1" "pkg2"` - Install with progress
- `pkg_select_interactive` - Gum-based selection
- `pkg_generate_autostart` - Generate autostart.conf

## Nested AGENTS.md

- `omarchy-config/.config/hypr/AGENTS.md` - Hyprland/Hy3 specific guidance
