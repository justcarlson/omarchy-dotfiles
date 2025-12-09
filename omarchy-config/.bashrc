# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
alias cursor='cursor-wayland'
alias code='cursor-wayland'
export PATH="$HOME/.local/bin:$PATH"

# 1Password SSH agent
export SSH_AUTH_SOCK=~/.1password/agent.sock

# Factory CLI aliases
# Exec mode (non-interactive) - supports -m for model selection
alias d-skip='droid exec --skip-permissions-unsafe'
alias d-yolo='droid exec --skip-permissions-unsafe'
alias d-yolo-o='droid exec --skip-permissions-unsafe -m claude-opus-4-5-20251101'
alias d-yolo-s='droid exec --skip-permissions-unsafe -m claude-sonnet-4-5-20250929'
alias d-yolo-h='droid exec --skip-permissions-unsafe -m claude-haiku-4-5-20251001'

# Interactive mode - only supports --resume
alias d-resume='droid --resume'
alias d-r='droid --resume'

# Created by `pipx` on 2025-11-29 19:23:05
export PATH="$PATH:/home/justincarlson/.local/bin"

# Created by `pipx` on 2025-12-08 17:46:40
export PATH="$PATH:/home/justincarlson/.dotfiles/omarchy-config/.local/bin"
