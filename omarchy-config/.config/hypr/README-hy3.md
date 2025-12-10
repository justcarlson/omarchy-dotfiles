# Hy3 Plugin Configuration

i3/sway-like manual tiling for Hyprland via the [Hy3 plugin](https://github.com/outfoxxed/hy3).

## Installation

```bash
# Install build dependencies
yay -S meson cmake cpio

# Setup hyprpm and install Hy3
hyprpm update
hyprpm add https://github.com/outfoxxed/hy3
hyprpm enable hy3

# Restart Hyprland
```

## Keybindings

| Key | Action |
|-----|--------|
| SUPER + T | Toggle tab group |
| SUPER + V | Vertical split |
| SUPER + H | Horizontal split |
| SUPER + Arrow | Move focus (hy3:movefocus) |
| SUPER + SHIFT + Arrow | Move window (hy3:movewindow) |
| SUPER + CTRL + LEFT/RIGHT | Focus tab left/right |

## Autotile Settings

Windows auto-split based on dimensions:
- `trigger_width = 800` - Split vertically if window < 800px wide
- `trigger_height = 500` - Split horizontally if window < 500px tall

## After Hyprland Updates

Hy3 must be recompiled when Hyprland updates:

```bash
hyprpm update
```

If it fails, try:
```bash
hyprpm update -f
```

## Disabling Hy3

Comment out in `hyprland.conf`:
```ini
# source = ~/.config/hypr/hy3.conf
```

Remove from autostart.conf:
```ini
# exec-once = hyprpm reload -n
```
