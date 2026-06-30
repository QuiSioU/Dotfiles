#!/usr/bin/env zsh
# zsh/zprofile.zsh


# Source default profile config
[ -f "$HOME/.config/zsh/default/profile.zsh" ] && . "$HOME/.config/zsh/default/profile.zsh"

# Source user profile config
[ -f "$HOME/.config/zsh/user/profile.zsh" ] && . "$HOME/.config/zsh/user/profile.zsh"
