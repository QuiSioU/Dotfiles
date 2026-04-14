#!/bin/bash
# bash/bash_env.sh


# Default terminal code editor
export EDITOR="nvim"

# Path stuff
export PATH="$HOME/.local/bin:$PATH"

# Lib path stuff
export LD_LIBRARY_PATH="$HOME/.local/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
