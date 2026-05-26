#!/bin/bash
# awww/setup.sh


echo "╔═══════════════════════════════╗"
echo "║ Setting up awww configuration ║"
echo "╚═══════════════════════════════╝"
echo ""

echo "Setting default wallpaper if cache is missing..."

if [ -f "$HOME/.cache/awww/0.12.0/eDP-1" ]; then
    echo "    skipped    $HOME/.cache/awww/0.12.0/eDP-1:  cached wallpaper already exists"
else
    awww img "$HOME/.config/awww/default/Leshy.jpg" --transition-type center
    echo "    created    $HOME/.cache/awww/0.12.0/eDP-1"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Awww configured successfully!"
