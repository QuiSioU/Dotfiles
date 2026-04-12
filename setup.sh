#!/bin/sh

# hypr/setup.sh

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

echo "Running setup scripts from $DOTFILES_DIR..."
echo ""
 
found=0
 
for dir in "$DOTFILES_DIR"/*/; do
    dir="${dir%/}"
    target="$CONFIG_DIR/$(basename "$dir")"

    # Create symlink in .config
    if [ -L "$target" ]; then
        echo ">>> $dir: symlink already exists, skipping"
    elif [ -e "$target" ]; then
        echo ">>> $dir: $target already exists and is not a symlink, skipping"
    else
        ln -s "$dir" "$target"
        echo ">>> $dir: linked $dir -> $target"
    fi

    script="$dir/setup.sh"
    if [ -f "$script" ]; then
        echo ">>> $(basename "$dir")"
        bash "$script"
        echo ""
        found=$((found + 1))
    fi
done
 
if [ "$found" -eq 0 ]; then
    echo "No setup.sh scripts found in any subdirectory."
fi
 
echo "All done!"
