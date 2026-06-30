#!/bin/sh
# elysian_themes/setup.sh


flag_force=false
while getopts "fn" opt; do
    case "$opt" in
        f) flag_force=true ;;
        n) ;;
        *) echo "Usage: $0 [-f]"; exit 1 ;;
    esac
done

echo "╔═════════════════════════════════════════╗"
echo "║ Setting up elysian themes configuration ║"
echo "╚═════════════════════════════════════════╝"
echo ""

CONFIG_DIR="$HOME/.config"
ROOT_DIR=$(cd "$(dirname "$0")" && pwd)

echo "Creating symlink in $CONFIG_DIR..."

symlink_src="${ROOT_DIR%/}"
symlink_dst="$CONFIG_DIR/$(basename "$symlink_src")"

if [ "$flag_force" = true ]; then
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

USER_DIR="$ROOT_DIR/themes/user"

echo "Creating directory structure for user's custom themes..."

if [ -d "$USER_DIR" ]; then
    echo "    skipped    $USER_DIR/:  directory already exists"
else
    mkdir -p "$USER_DIR"
    echo "    created    $USER_DIR/"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Setting active theme configuration files..."

if [ -d "$ROOT_DIR/active_theme" ] && [ "$flag_force" = false ]; then
    echo "    skipped    $ROOT_DIR/active_theme/:  directory already exists"
else
    if [ "$flag_force" = true ]; then
        rm -rf "$ROOT_DIR/active_theme"
    fi

    python3 "$ROOT_DIR/set_theme.py" "$ROOT_DIR/themes/default/TokyoCarbon.toml"
    echo "    created    $ROOT_DIR/active_theme/"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Elysian themes configured successfully!"
