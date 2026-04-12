# bash_profile.sh

[[ -f "$HOME/.bash_env" ]]	&& . "$HOME/.bash_env"
[[ -f "$HOME/.bash_env_priv" ]]	&& . "$HOME/.bash_env_priv"

[[ -f "$HOME/.bashrc" ]] 	&& . "$HOME/.bashrc"

# Start Hyprland Automatically
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
	exec start-hyprland
fi
