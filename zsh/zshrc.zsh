#!/usr/bin/env zsh
# zsh/zshrc.zsh


# Save and set last visited directory when closing terminal
trap "pwd > $HOME/.last_dir" EXIT
if [ -f "$HOME/.last_dir" ]; then
	export OLDPWD="$(cat $HOME/.last_dir)"
fi

# Set command history
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000
setopt HIST_IGNORE_DUPS     # don't store a line identical to the immediately preceding one
setopt HIST_FIND_NO_DUPS    # when searching history, skip consecutive duplicates while scrolling
setopt EXTENDED_HISTORY     # record a timestamp (and duration) for each history entry
setopt INC_APPEND_HISTORY   # write each command to HISTFILE immediately, not just on shell exit


# System's command completions must be enabled by user manually.
# If you use a declarative configuration (like NixOS), do it there.
# Otherwise, you can create this file and place the commands in it.
[ -f "$HOME/.config/zsh/user/enable_completions.zsh" ] && . "$HOME/.config/zsh/user/enable_completions.zsh"

# Source custom zsh files
load_scripts() {
    if [ -d "$1" ]; then
        for script in "$1"/*.zsh; do
            [ -e "$script" ] || continue
            [ "$script" = "$HOME/.config/zsh/user/env.zsh" ] && continue
			[ -r "$script" ] && . "$script" # Source every readable file inside the directory
        done
    fi
}
CONFIG_DIR="$HOME/.config/zsh"
load_scripts "$CONFIG_DIR/default"  # Load Main Scripts (Git Tracked)
load_scripts "$CONFIG_DIR/user"	    # Load User Scripts (Git Untracked). May be used to override
unset -f load_scripts

# Init starship
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi
