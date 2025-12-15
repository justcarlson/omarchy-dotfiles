# Keybindings & Aliases

## Hyprland Keybindings

### Core Apps (always available)

| Keybinding | Action |
|------------|--------|
| `Super + Return` | Terminal (in current directory) |
| `Super + Shift + B` | Browser |
| `Super + Shift + Alt + B` | Browser (private window) |
| `Super + Shift + N` | Editor |
| `Super + Shift + /` | 1Password |

### Optional Apps (guarded)

These show a notification with install instructions if the app isn't installed.

| Keybinding | Action | Install |
|------------|--------|---------|
| `Super + Shift + F` | File manager (Nautilus) | Pre-installed |
| `Super + Shift + T` | Activity monitor (btop) | `yay -S btop` |
| `Super + Shift + D` | Docker (lazydocker) | `yay -S lazydocker` |
| `Super + Shift + W` | Typora | `yay -S typora` |
| `Super + Shift + I` | Cursor IDE | `yay -S cursor-bin` |

### Communication Apps

| Keybinding | Action |
|------------|--------|
| `Super + Shift + M` | Music (Spotify) |
| `Super + Shift + G` | Signal |
| `Super + Shift + O` | Obsidian |

### AI Tools

| Keybinding | Action |
|------------|--------|
| `Super + Shift + A` | Claude (web) |
| `Super + Shift + Alt + A` | OpenCode (primary CLI agent) |
| `Super + Shift + Ctrl + A` | Claude Code (fallback CLI agent) |

### Web Apps

| Keybinding | Action |
|------------|--------|
| `Super + Shift + C` | Google Calendar |
| `Super + Shift + E` | Email (Gmail) |
| `Super + Shift + Y` | YouTube |
| `Super + Shift + Alt + G` | WhatsApp |
| `Super + Shift + Ctrl + G` | Google Messages |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + X` | X (Twitter) |
| `Super + Shift + Alt + X` | X Post (compose) |

### Screenshots

| Keybinding | Action |
|------------|--------|
| `Alt + Shift + S` | Screenshot to clipboard (Logitech keyboard) |
| `Alt + Shift + Ctrl + S` | Screenshot with editing (Logitech keyboard) |
| `Super + Shift + S` | Screenshot to clipboard (MacBook keyboard) |
| `Super + Shift + Ctrl + S` | Screenshot with editing (MacBook keyboard) |

## Bash Aliases

### OpenCode (Primary CLI Agent)

| Alias | Command | Description |
|-------|---------|-------------|
| `oc` | `opencode` | Launch OpenCode |
| `oc-c` | `opencode --continue` | Continue last session |
| `oc-s` | `opencode --session` | Resume specific session |
| `oc-run` | `opencode run` | Non-interactive run |

### Claude Code (Fallback CLI Agent)

| Alias | Command | Description |
|-------|---------|-------------|
| `c-yolo` | `claude --dangerously-skip-permissions` | Skip permission prompts |
| `c-continue` | `claude --continue` | Continue last session |
| `c-resume` | `claude --resume` | Resume with session picker |
| `c-print` | `claude --print` | Non-interactive output |
