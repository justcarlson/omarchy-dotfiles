---
parent: [AGENTS.md](../../AGENTS.md)
---

# Hyprland Configuration

## Config Structure

```
~/.config/hypr/
├── hyprland.conf         # Main config, sources all others
├── autostart.conf        # Core autostart (plugins, essential services)
├── autostart-apps.conf   # App autostart (generated from package registry)
├── autostart-opencode.conf # OpenCode workspace sessions (optional)
├── hy3.conf              # Hy3 plugin settings + keybind overrides
├── bindings.conf         # Personal app launch keybindings
├── monitors.conf         # Display configuration
├── input.conf            # Input device settings
├── looknfeel.conf        # Theme and appearance
└── envs.conf             # Environment variables
```

## Autostart Files

| File | Regenerated? |
|------|--------------|
| `autostart.conf` | No |
| `autostart-apps.conf` | Yes, by install.sh |
| `autostart-opencode.conf` | No |

## Commands

```bash
hyprctl reload                          # Reload config
hyprpm list                             # List plugins
hyprpm update                           # Update headers + plugins
hyprpm enable hy3                       # Enable Hy3

# Regenerate autostart-apps.conf
cd ~/.dotfiles && source lib/packages.sh && pkg_write_autostart_file
```

## Boundaries

- **Always:** Test with `hyprctl reload` after changes
- **Always:** Use guard patterns for optional apps
- **Never:** Edit `~/.local/share/omarchy/` — override in personal configs
- **Never:** Hardcode app paths without guards

## Patterns

**Guard pattern (autostart and bindings):**
```ini
exec-once = command -v app &>/dev/null && uwsm-app -- app
```

**Override default bindings:**
```ini
unbind = SUPER, KEY
bindd = SUPER, KEY, Desc, dispatcher, args
```

**Guarded keybinding:**
```ini
bindd = SUPER SHIFT, T, Activity, exec, command -v btop &>/dev/null && $terminal -e btop || notify-send "btop not installed" "Install with: yay -S btop"
```

**Autostart with window rules:**
```ini
exec-once = [workspace 1] uwsm-app -- app-name
```

## Autostart Gotchas

`exec-once` passes arguments literally — use wrapper scripts for complex commands:

```ini
# Wrong - arguments get mangled
exec-once = uwsm-app -- xdg-terminal-exec -e opencode -m model

# Correct - use shell wrapper
exec-once = uwsm-app -- ghostty -e bash -c 'opencode; exec $SHELL'
```
