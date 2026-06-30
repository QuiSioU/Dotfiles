#!/usr/bin/env zsh
# zsh/default/main.zsh


# Save and set last visited directory when closing terminal
trap "pwd > $HOME/.last_dir" EXIT
if [ -f "$HOME/.last_dir" ]; then
	export OLDPWD="$(cat $HOME/.last_dir)"
fi

# System's command completions must be enabled by user manually.
# If you use a declarative configuration (like NixOS), do it there.
# Otherwise, you can create this file and place the commands in it.
[ -f "$HOME/.config/zsh/user/enable_completions.zsh" ] && . "$HOME/.config/zsh/user/enable_completions.zsh"

# Source custom zsh files
[ -f "$HOME/.config/zsh/default/alias.zsh" ] && . "$HOME/.config/zsh/default/alias.zsh"
[ -f "$HOME/.config/zsh/default/functions.zsh" ] && . "$HOME/.config/zsh/default/functions.zsh"
CONFIG_DIR="$HOME/.config/zsh"
if [ -d "$CONFIG_DIR/user" ]; then
    for script in "$CONFIG_DIR/user"/*.zsh; do
        [ -e "$script" ] || continue
        [ -r "$script" ] && . "$script" # Source every readable file inside the user directory
    done
fi
