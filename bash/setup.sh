#!/bin/sh

# bash/setup.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo "Running setup scripts from $ROOT_DIR..."
echo ""

for dir in bash*.sh; do
    target="$HOME/.$(basename "${dir%.sh}")"

    # Create symlink in ~ (home)
    if [ -L "$target" ]; then
        echo ">>> $dir: symlink already exists, skipping"
    elif [ -e "$target" ]; then
        echo ">>> $dir: $target already exists and is not a symlink, skipping"
    else
        ln -s "$ROOT_DIR/$dir" "$target"
        echo ">>> $dir: linked $ROOT_DIR/$dir -> $target"
    fi
done

echo "All done!"
