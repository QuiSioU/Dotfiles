#!/bin/sh
# quickshell/setup.sh


set --
flag_f=false
flag_n=false
while getopts "fn" opt; do
    case "$opt" in
        f) flag_f=true ;;
        n) flag_n=true ;;
        *) echo "Usage: $0 [-f] [-n]"; exit 1 ;;
    esac
done

[ "$flag_f" = true ] && set -- "$@" "-f"
[ "$flag_n" = true ] && set -- "$@" "-n"

echo "╔═════════════════════════════════════╗"
echo "║ Setting up quickshell configuration ║"
echo "╚═════════════════════════════════════╝"
echo ""

CONFIG_DIR="$HOME/.config"
ROOT_DIR=$(cd "$(dirname "$0")" && pwd)
cd "$ROOT_DIR"

echo "Creating symlink in $CONFIG_DIR..."

symlink_src="${ROOT_DIR%/}"
symlink_dst="$CONFIG_DIR/$(basename "$symlink_src")"

if [ "$flag_f" = true ]; then
    rm -f "$symlink_dst"
fi

if [ -L "$symlink_dst" ]; then
    echo "    skipped    $symlink_dst: file already exists (symlink)"
elif [ -e "$symlink_dst" ]; then
    echo "    skipped    $symlink_dst: file already exists (not symlink)"
else
    ln -s "$symlink_src" "$symlink_dst"
    echo "    linked     $symlink_src -> $symlink_dst"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Building modules..."

[ -f "build.sh" ] && chmod +x "build.sh" && ./build.sh

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

for dir in "$ROOT_DIR"/*/; do
    script="${dir}setup.sh"
    [ -f "$script" ] && chmod +x "$script" && "$script" "$@"
done

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Quickshell configured successfully!"
