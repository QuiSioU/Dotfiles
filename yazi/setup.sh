#!/bin/bash
# yazi/setup.sh


echo "╔═══════════════════════════════╗"
echo "║ Setting up yazi configuration ║"
echo "╚═══════════════════════════════╝"
echo ""

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$ROOT_DIR"

target="theme.toml"
dir="$HOME/.config/elysean_themes/active_theme/yazi.toml"

echo "Setting up color theme configuration file..."

if [ -L "$target" ]; then
    echo "    skipped    $target: file already exists (symlink)"
elif [ -e "$target" ]; then
    echo "    skipped    $target: file already exists (not symlink)"
else
    ln -s "$dir" "$target"
    echo "    linked     $dir -> $target"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Yazi configured successfully!"
