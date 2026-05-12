#!/bin/bash
# elysean_themes/setup.sh


echo "╔═════════════════════════════════════════╗"
echo "║ Setting up elysean themes configuration ║"
echo "╚═════════════════════════════════════════╝"
echo ""

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$ROOT_DIR"

THEME_USER_DIR="$ROOT_DIR/themes/user"
WP_USER_DIR="$ROOT_DIR/wallpapers/user"

echo "Creating directory structure for user's custom themes and wallpapers..."

if [ -d "$THEME_USER_DIR" ]; then
    echo "    skipped    $THEME_USER_DIR/:  directory already exists"
else
    mkdir -p "$THEME_USER_DIR"
    echo "    created    $THEME_USER_DIR/"
fi

if [ -d "$WP_USER_DIR" ]; then
    echo "    skipped    $WP_USER_DIR/:  directory already exists"
else
    mkdir -p "$WP_USER_DIR"
    echo "    created    $WP_USER_DIR/"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Setting active theme configuration file..."

if [ -f "$ROOT_DIR/active_theme" ]; then
    echo "    skipped    $ROOT_DIR/active_theme:  file already exists"
else
    cp "themes/default/TokyoNight.conf" "active_theme"
    echo "    created    $ROOT_DIR/active_theme"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Elysean themes configured successfully!"
