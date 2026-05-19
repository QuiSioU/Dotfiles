#!/bin/bash
# bash/bash_env.sh


# Default terminal code editor
export EDITOR="nvim"

# Path stuff
export PATH="$HOME/.local/bin:$PATH"

# Lib path stuff
export LD_LIBRARY_PATH="$HOME/.local/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# LESS command formatting
export GROFF_NO_SGR=1
export LESS_TERMCAP_mb=$'\e[5;38;2;180;164;245m'                # blink start (text that flashes)
export LESS_TERMCAP_md=$'\e[1;38;2;180;164;245m'                # bold start (section headers, command names...)
export LESS_TERMCAP_me=$'\e[0m'                                 # bold/blink end (reset after bold or blink)
export LESS_TERMCAP_mh=$'\e[2;38;2;86;95;137m'                  # dim start (faded/less important text)
export LESS_TERMCAP_mr=$'\e[38;2;26;27;46;48;2;187;154;247m'    # reverse video start (swaps fg/bg colors)
export LESS_TERMCAP_so=$'\e[38;2;192;202;245;48;2;36;40;59m'    # standout start (status bar, search matches)
export LESS_TERMCAP_se=$'\e[0m'                                 # standout end (reset after standout)
export LESS_TERMCAP_us=$'\e[4;1;38;2;42;195;222m'               # underline start (option flags, emphasized text)
export LESS_TERMCAP_ue=$'\e[0m'                                 # underline end (reset after underline)
export LESS_TERMCAP_ZN=$'\e[74m'                                # subscript start
export LESS_TERMCAP_ZV=$'\e[75m'                                # subscript end
export LESS_TERMCAP_ZO=$'\e[73m'                                # superscript start
export LESS_TERMCAP_ZW=$'\e[75m'                                # superscript end
