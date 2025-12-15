# Hyprland Configuration

Personal Hyprland config for Omarchy Linux. Uses Hy3 plugin for i3-like tiling.

## Config Structure

```
~/.config/hypr/
├── hyprland.conf         # Main config, sources all others
├── autostart.conf        # Core autostart (plugins, essential services)
├── autostart-apps.conf   # App autostart (generated from package registry)
├── autostart-claude.conf # Claude Code workspace sessions (optional)
├── hy3.conf              # Hy3 plugin settings + keybind overrides
├── bindings.conf         # Personal app launch keybindings
├── monitors.conf         # Display configuration
├── input.conf            # Input device settings
├── looknfeel.conf        # Theme and appearance
└── envs.conf             # Environment variables
```

## Autostart Files

| File | Purpose | Regenerated? |
|------|---------|--------------|
| `autostart.conf` | Core services (hyprpm) | No |
| `autostart-apps.conf` | Apps from package registry | Yes, by install.sh |
| `autostart-claude.conf` | Claude Code terminals | No |

**Guard pattern:** All app entries use guards for graceful degradation:
```ini
exec-once = command -v app &>/dev/null && uwsm-app -- app
```

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

# Regenerate autostart-apps.conf
cd ~/.dotfiles && source lib/packages.sh && pkg_write_autostart_file
```

## Boundaries

- ✅ **Always:** Test with `hyprctl reload` after changes
- ✅ **Always:** Use guard patterns for optional apps (both autostart and keybindings)
- ✅ **Always:** Include install instructions in notify-send fallback for guarded bindings
- ⚠️ **Ask first:** Modifying default Omarchy bindings (they live in `~/.local/share/omarchy/`)
- 🚫 **Never:** Edit files in `~/.local/share/omarchy/` - override in personal configs instead
- 🚫 **Never:** Hardcode app paths without guards

## Patterns

**Override default bindings:**
```ini
unbind = SUPER, KEY           # Remove default
bindd = SUPER, KEY, Desc, dispatcher, args
```

**Guarded keybinding (for optional apps):**
```ini
# Shows notification with install instructions if app not found
bindd = SUPER SHIFT, T, Activity, exec, command -v btop &>/dev/null && $terminal -e btop || notify-send "btop not installed" "Install with: yay -S btop"
```

**Autostart with window rules:**
```ini
exec-once = [workspace 1] uwsm-app -- app-name
```

**Guarded autostart (preferred):**
```ini
exec-once = command -v app &>/dev/null && uwsm-app -- app
```

**Source order matters** - later sources override earlier ones.

## Autostart Gotchas

Hyprland's `exec-once` passes arguments literally. For complex commands, use wrapper scripts:

```ini
# Wrong - arguments get mangled
exec-once = uwsm-app -- xdg-terminal-exec -e claude -m model

# Correct - use wrapper script or shell
exec-once = uwsm-app -- ghostty -e bash -c 'claude; exec $SHELL'
```

## Claude Code Quick Reference

```bash
claude                   # Interactive mode
claude --continue        # Continue last session
claude --resume          # Resume with picker
claude --print           # Non-interactive output
```

Aliases in `.bashrc`: `c-yolo`, `c-continue`, `c-resume`, `c-print`
