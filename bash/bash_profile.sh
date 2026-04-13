#!/bin/bash

# bash/bash_profile.sh

[[ -f "$HOME/.bash_env" ]]		&& . "$HOME/.bash_env"
[[ -f "$HOME/.bash_env_priv" ]]	&& . "$HOME/.bash_env_priv"

[[ -f "$HOME/.bashrc" ]] 		&& . "$HOME/.bashrc"

# Start Hyprland Automatically
# On TTY1 only, so if something breaks, you're still able to log in without hyprland on another TTY
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
	exec start-hyprland
fi
