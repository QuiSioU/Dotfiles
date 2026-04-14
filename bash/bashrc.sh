#!/bin/bash

# bash/bashrc.sh

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ll='ls -lahF'
alias la='ls -A'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# Save and set last visited directory when closing terminal
trap "pwd > $HOME/.last_dir" EXIT
if [[ -f "$HOME/.last_dir" ]]; then
	export OLDPWD="$(cat $HOME/.last_dir)"
fi

# Set command history
export HISTSIZE=10000
export HISTCONTROL=ignoredups
export HISTTIMEFORMAT="(%F %T) "
shopt -s histappend

# System's bash completions
[ -f /usr/share/bash-completion/completions/git ] && source /usr/share/bash-completion/completions/git

# Source custom bash files
load_scripts() {
    local dir="$1"
    if [ -d "$dir" ]; then
        shopt -s nullglob
        for script in "$dir"/*.sh; do
			[ -r "$script" ] && source "$script" # Source every readable file inside the directory
        done
        shopt -u nullglob
    fi
}
CONFIG_DIR="$HOME/.config/bash"
load_scripts "$CONFIG_DIR/default"  # Load Main Scripts (Git Tracked)
load_scripts "$CONFIG_DIR/user"	    # Load User Scripts (Git Untracked). May be used to override
unset -f load_scripts

# Init starship
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi
