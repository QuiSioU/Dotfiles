#!/usr/bin/env bash
# setup.sh


DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

args=()
flag_force=false
while getopts "f" opt; do
    case "$opt" in
        f) args+=("-f") ;;
        *) echo "Usage: $0 [-f]"; exit 1 ;;
    esac
done

# 1. Run the critical theme dependency first
if [ -f "$DOTFILES_DIR/elysian_themes/setup.sh" ]; then
    echo ""
    echo ""
    bash "$DOTFILES_DIR/elysian_themes/setup.sh" "${args[@]}"
fi

for dir in "$DOTFILES_DIR"/*/; do
    dir_name=$(basename "$dir")

    # Skip elysian_themes since it ran first
    if [ "$dir_name" = "elysian_themes" ]; then
        continue
    fi

    script="${dir}setup.sh"
    if [ -f "$script" ]; then
        echo ""
        echo ""
        bash "$script" "${args[@]}"
        echo ""
    fi
done

echo -e "\nAll done!\n"
