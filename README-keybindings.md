# Keybindings & Aliases

## Hyprland Keybindings

### Applications

| Keybinding | Action |
|------------|--------|
| `Super + Return` | Terminal (in current directory) |
| `Super + Shift + F` | File manager (Nautilus) |
| `Super + Shift + B` | Browser |
| `Super + Shift + Alt + B` | Browser (private window) |
| `Super + Shift + M` | Music (Spotify) |
| `Super + Shift + N` | Editor |
| `Super + Shift + T` | Activity monitor (btop) |
| `Super + Shift + D` | Docker (lazydocker) |
| `Super + Shift + G` | Signal |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Typora |
| `Super + Shift + /` | 1Password |
| `Super + Shift + I` | PyGPT |
| `Super + Shift + E` | Cursor / Email |

### AI Tools

| Keybinding | Action |
|------------|--------|
| `Super + Shift + A` | Claude (web) |
| `Super + Shift + Alt + A` | Factory CLI (droid with spec mode + Opus) |

### Web Apps

| Keybinding | Action |
|------------|--------|
| `Super + Shift + C` | Google Calendar |
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

### Editor

| Alias | Command |
|-------|---------|
| `cursor` | `cursor-wayland` |
| `code` | `cursor-wayland` |

### Factory CLI (droid)

#### Basic

| Alias | Command | Description |
|-------|---------|-------------|
| `d-spec` | `droid --use-spec` | Start in spec mode |
| `d-s` | `droid --use-spec` | Start in spec mode (short) |
| `d-skip` | `droid exec --skip-permissions-unsafe` | Exec without permission prompts |
| `d-resume` | `droid --resume` | Resume last session |
| `d-r` | `droid --resume` | Resume last session (short) |

#### Model Selection

| Alias | Command | Model |
|-------|---------|-------|
| `d-opus` | `droid -m claude-opus-4-5-20251101` | Claude Opus 4.5 |
| `d-sonnet` | `droid -m claude-sonnet-4-5-20250929` | Claude Sonnet 4.5 |
| `d-haiku` | `droid -m claude-haiku-4-5-20251001` | Claude Haiku 4.5 |

#### Combo: Skip Permissions + Model

| Alias | Command |
|-------|---------|
| `d-yolo` | `droid exec --skip-permissions-unsafe` |
| `d-yolo-o` | `droid exec --skip-permissions-unsafe -m claude-opus-4-5-20251101` |
| `d-yolo-s` | `droid exec --skip-permissions-unsafe -m claude-sonnet-4-5-20250929` |
| `d-yolo-h` | `droid exec --skip-permissions-unsafe -m claude-haiku-4-5-20251001` |

#### Combo: Resume + Model

| Alias | Command |
|-------|---------|
| `d-r-o` | `droid --resume -m claude-opus-4-5-20251101` |
| `d-r-s` | `droid --resume -m claude-sonnet-4-5-20250929` |
| `d-r-h` | `droid --resume -m claude-haiku-4-5-20251001` |
