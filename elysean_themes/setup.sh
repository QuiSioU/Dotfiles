#!/bin/bash
# elysean_themes/setup.sh


echo "╔═════════════════════════════════════════╗"
echo "║ Setting up elysean themes configuration ║"
echo "╚═════════════════════════════════════════╝"
echo ""

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$ROOT_DIR"

USER_DIR="$ROOT_DIR/user"

echo "Creating directory structure for user's custom themes..."

if [ -d "$USER_DIR" ]; then
    echo "  skipped    $USER_DIR/:  directory already exists"
else
    mkdir -p "$USER_DIR"
    echo "  created    $USER_DIR/"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Linking active theme configuration file..."

if [ -f "$ROOT_DIR/active_theme" ]; then
    echo "  skipped    $ROOT_DIR/active_theme:  file already exists"
else
    ln -s "default/TokyoNight.conf" "active_theme"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Elysean themes configured successfully!"
