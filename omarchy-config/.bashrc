# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
export PATH="$HOME/.local/bin:$PATH"

# 1Password SSH agent
export SSH_AUTH_SOCK=~/.1password/agent.sock

# Claude Code CLI aliases
alias c-dsp='claude --dangerously-skip-permissions'
alias c-continue='claude --continue'
alias c-c='claude --continue'
alias c-print='claude --print'
alias c-p='claude --print'
alias c-verbose='claude --verbose'
alias c-v='claude --verbose'

# Claude model aliases
alias c-opus='claude --model opus'
alias c-sonnet='claude --model sonnet'
alias c-haiku='claude --model haiku'

# Claude combo aliases
alias c-yolo='claude --dangerously-skip-permissions --model opus'
alias c-resume='claude --resume'
alias c-r='claude --resume'

# Created by `pipx` on 2025-11-29 19:23:05
export PATH="$PATH:/home/justincarlson/.local/bin"
