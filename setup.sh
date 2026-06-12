#!/usr/bin/env bash
# setup.sh


DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

flag_force=false
while getopts "f" opt; do
    case "$opt" in
        f) flag_force=true ;;
        *) echo "Usage: $0 [-f]"; exit 1 ;;
    esac
done

echo ""
echo "Creating symlinks in $CONFIG_DIR..."
for dir in "$DOTFILES_DIR"/*/; do
    dir="${dir%/}"
    target="$CONFIG_DIR/$(basename "$dir")"

    if [ -L "$target" ]; then
        echo "    skipped    $target: file already exists (symlink)"
    elif [ -e "$target" ]; then
        echo "    skipped    $target: file already exists (not symlink)"
    else
        ln -s "$dir" "$target"
        echo "    linked     $dir -> $target"
    fi
done
echo ""

for dir in "$DOTFILES_DIR"/*/; do
    script="${dir%/}/setup.sh"
    if [ -f "$script" ]; then
        echo ""
        echo ""
        if [ "$flag_force" = true ]; then
            bash "$script" -f
        else
            bash "$script"
        fi
        echo ""
    fi
done

echo ""
echo "All done!"
echo ""
