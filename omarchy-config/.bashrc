# shellcheck shell=bash
# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# Source secrets first (available in both bash and fish via exec)
[[ -f ~/.secrets ]] && source ~/.secrets

# Load shell preference (defaults to bash)
[[ -f ~/.config/omarchy/shell ]] && OMARCHY_SHELL=$(cat ~/.config/omarchy/shell)
OMARCHY_SHELL="${OMARCHY_SHELL:-bash}"

# Auto-launch fish shell if preference is set to fish
if [[ "$OMARCHY_SHELL" == "fish" ]] && command -v fish &> /dev/null; then
	if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ${BASH_EXECUTION_STRING} && ${SHLVL} == 1 ]]
	then
		shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
		exec fish $LOGIN_OPTION
	fi
fi

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions below.
