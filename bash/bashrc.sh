# bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# System's bash completions
. /usr/share/bash-completion/completions/git

# Some more ls aliases
alias ll='ls -lahF'
alias la='ls -A'

# Personal aliases
[[ -f "$HOME/.bash_aliases" ]]   	&& . "$HOME/.bash_aliases"
[[ -f "$HOME/.bash_aliases_priv" ]]	&& . "$HOME/.bash_aliases_priv"

# Personal functions
[[ -f "$HOME/.bash_functions" ]]  	&& . "$HOME/.bash_functions"

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

# Starship init
eval "$(starship init bash)"
