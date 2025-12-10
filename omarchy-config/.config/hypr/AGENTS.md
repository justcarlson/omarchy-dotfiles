# Hyprland Configuration

Personal Hyprland config for Omarchy Linux. Uses Hy3 plugin for i3-like tiling.

## Key Files

- `hyprland.conf` - Main config, sources all others
- `hy3.conf` - Hy3 plugin settings + keybind overrides
- `bindings.conf` - Personal app launch keybindings
- `autostart.conf` - Startup applications + Droid sessions
- `monitors.conf` - Display configuration

## Tech Stack

- **Hyprland** - Wayland compositor
- **Hy3 plugin** - i3/sway-like manual tiling (via hyprpm)
- **uwsm** - Session manager for app launching
- **Ghostty** - Terminal emulator

## Commands

```bash
# Reload config (no restart needed)
hyprctl reload

# Check for config errors
hyprland --config ~/.config/hypr/hyprland.conf --check

# Plugin management
hyprpm list                    # List installed plugins
hyprpm update                  # Update headers + plugins
hyprpm enable hy3              # Enable Hy3 after install
```

## Boundaries

- ✅ **Always:** Test with `hyprctl reload` after changes
- ⚠️ **Ask first:** Modifying default Omarchy bindings (they live in `~/.local/share/omarchy/`)
- 🚫 **Never:** Edit files in `~/.local/share/omarchy/` - override in personal configs instead

## Patterns

**Override default bindings:**
```ini
unbind = SUPER, KEY           # Remove default
bindd = SUPER, KEY, Desc, dispatcher, args
```

**Autostart with window rules:**
```ini
exec-once = [workspace 1] uwsm-app -- app-name
```

**Source order matters** - later sources override earlier ones.

## Autostart Gotchas

Hyprland's `exec-once` passes arguments literally. For complex commands, use wrapper scripts:

```ini
# Wrong - arguments get mangled
exec-once = uwsm-app -- xdg-terminal-exec -e droid -m model

# Correct - use wrapper script or shell
exec-once = uwsm-app -- ghostty -e bash -c 'droid; exec $SHELL'
```

## Factory CLI (droid) Quick Reference

```bash
droid                    # Interactive mode (no model flag)
droid "prompt"           # Start with context
droid --resume           # Resume last session
droid exec -m model      # Exec mode supports -m flag
```

**Note:** Model selection (`-m`) only works in `droid exec`, not interactive mode.
