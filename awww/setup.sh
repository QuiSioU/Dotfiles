#!/bin/bash
# awww/setup.sh


echo "╔═══════════════════════════════╗"
echo "║ Setting up awww configuration ║"
echo "╚═══════════════════════════════╝"
echo ""

echo "Setting default wallpaper if cache is missing..."

AWWW_VERSION=$(awww --version | awk '{print $2}')

if [ -z "$AWWW_VERSION" ]; then
    echo "Error: Could not detect awww version."
    exit 1
fi

# This only works for 1 monitor

CACHE_FILE="$HOME/.cache/awww/$AWWW_VERSION/eDP-1"

if [ -f "$CACHE_FILE" ]; then
    echo "    skipped    $CACHE_FILE:  cached wallpaper already exists"
else
    awww img "$HOME/.config/awww/default/Leshy.jpg" --transition-type center
    echo "    created    $CACHE_FILE"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Awww configured successfully!"
