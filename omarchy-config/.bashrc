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

# Claude Code aliases
alias c-yolo='claude --dangerously-skip-permissions'
alias c-yolo-o='claude --dangerously-skip-permissions --model opus'
alias c-yolo-s='claude --dangerously-skip-permissions --model sonnet'
alias c-yolo-h='claude --dangerously-skip-permissions --model haiku'
alias c-continue='claude --continue'
alias c-c='claude --continue'
alias c-resume='claude --resume'
alias c-r='claude --resume'
alias c-print='claude --print'
alias c-p='claude --print'

# Created by `pipx` on 2025-11-29 19:23:05
export PATH="$PATH:/home/justincarlson/.local/bin"

# Created by `pipx` on 2025-12-08 17:46:40
export PATH="$PATH:/home/justincarlson/.dotfiles/omarchy-config/.local/bin"
