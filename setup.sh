#!/bin/bash
# setup.sh


DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

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
        bash "$script"
        echo ""
    fi
done

echo ""
echo "All done!"
echo ""

