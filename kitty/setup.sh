#!/usr/bin/env bash
# kitty/setup.sh


flag_force=false
while getopts "f" opt; do
    case "$opt" in
        f) flag_force=true ;;
        *) echo "Usage: $0 [-f]"; exit 1 ;;
    esac
done

echo "╔════════════════════════════════╗"
echo "║ Setting up kitty configuration ║"
echo "╚════════════════════════════════╝"
echo ""

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$ROOT_DIR"

target="theme.conf"
dir="$HOME/.config/elysian_themes/active_theme/kitty.conf"

echo "Setting up color theme configuration file..."

if [ "$flag_force" = true ]; then
    rm -f "$target"
fi

if [ -L "$target" ]; then
    echo "    skipped    $target: file already exists (symlink)"
elif [ -e "$target" ]; then
    echo "    skipped    $target: file already exists (not symlink)"
else
    ln -s "$dir" "$target"
    echo "    linked     $dir -> $target"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Kitty configured successfully!"
