#!/usr/bin/env zsh
# zsh/zshenv.zsh


# Source default environment variables
[ -f "$HOME/.config/zsh/default/env.zsh" ] && . "$HOME/.config/zsh/default/env.zsh"

# Source personal environment variables
[ -f "$HOME/.config/zsh/user/env.zsh" ] && . "$HOME/.config/zsh/user/env.zsh"
