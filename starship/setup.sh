#!/bin/bash
# starship/setup.sh


echo "╔═══════════════════════════════════╗"
echo "║ Setting up starship configuration ║"
echo "╚═══════════════════════════════════╝"
echo ""

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$ROOT_DIR"

target="starship.toml"
dir="$HOME/.config/elysean_themes/active_theme/starship.toml"

echo "Setting up main configuration file..."

if [ -L "$target" ]; then
    echo "    skipped    $target: file already exists (symlink)"
elif [ -e "$target" ]; then
    echo "    skipped    $target: file already exists (not symlink)"
else
    ln -s "$dir" "$target"
    echo "    linked     $dir -> $target"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Starship configured successfully!"
