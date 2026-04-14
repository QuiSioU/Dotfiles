#!/bin/bash

# bash/bash_profile.sh

[[ -f "$HOME/.bashrc" ]] && source "$HOME/.bashrc"

# Start Hyprland Automatically on TTY1 only, so if something breaks,
# you're still able to log in without hyprland on another TTY
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
	exec start-hyprland
fi
