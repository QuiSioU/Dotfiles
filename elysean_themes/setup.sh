#!/bin/bash
# elysean_themes/setup.sh


echo "╔═════════════════════════════════════════╗"
echo "║ Setting up elysean themes configuration ║"
echo "╚═════════════════════════════════════════╝"
echo ""

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$ROOT_DIR"

USER_DIR="$ROOT_DIR/themes/user"

echo "Creating directory structure for user's custom themes..."

if [ -d "$USER_DIR" ]; then
    echo "    skipped    $USER_DIR/:  directory already exists"
else
    mkdir -p "$USER_DIR"
    echo "    created    $USER_DIR/"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Setting active theme configuration file..."

if [ -d "$ROOT_DIR/active_theme" ]; then
    echo "    skipped    $ROOT_DIR/active_theme/:  directory already exists"
else
    python "set_theme.py" "themes/default/TokyoNight.toml"
    echo "    created    $ROOT_DIR/active_theme/"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Elysean themes configured successfully!"
