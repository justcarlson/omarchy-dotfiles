# Hyprland Configuration

## Autostart Commands

Hyprland's `exec-once` does not use a shell to parse commands. Arguments are passed literally, which breaks commands with flags like `droid -m model-name`.

### Adding commands with arguments

**Wrong** - arguments get mangled:
```
exec-once = uwsm-app -- xdg-terminal-exec -e bash -c 'droid -m claude-opus-4-5-20251101'
```

**Correct** - use a wrapper script:
```
exec-once = uwsm-app -- xdg-terminal-exec -e ~/.local/bin/droid-scripts/droid-opus
```

### Creating wrapper scripts

1. Add script to `omarchy-config/.local/bin/droid-scripts/`
2. Make it executable: `chmod +x script-name`
3. Run `stow omarchy-config` to symlink
4. Reference full path in autostart.conf: `~/.local/bin/droid-scripts/script-name`

### Command patterns

- GUI apps: `exec-once = uwsm-app -- app-name`
- Terminal apps: `exec-once = uwsm-app -- xdg-terminal-exec -e command`
- Silent/workspace: `exec-once = [workspace 1 silent] app-name`
