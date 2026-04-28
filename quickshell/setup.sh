#!/bin/bash
# quickshell/setup.sh


echo "╔═════════════════════════════════════╗"
echo "║ Setting up quickshell configuration ║"
echo "╚═════════════════════════════════════╝"
echo ""

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

THEME_DIR="$ROOT_DIR/themes"
USER_DIR="$THEME_DIR/user"

mkdir -p "$USER_DIR"

echo "Creating directory structure for user's custom themes..."

if [ -f "$USER_DIR/PlatypusTokyoNight.conf" ]; then
    echo "    skipped    $USER_DIR/PlatypusTokyoNight.conf: file already exists"
else
    cat > "$USER_DIR/PlatypusTokyoNight.conf" <<EOF
# quickshell/themes/default/WitcherTokyoNight.conf


# Only works for images inside the quickshell/assets/wallpapers directory
WALLPAPER_PATH=Platypus.jpg

COLOR_1=7dcfff
COLOR_2=7aa2f7
COLOR_3=bb9af7
COLOR_4=9ece6a
COLOR_5=ff9e64
COLOR_6=1a3a5c
COLOR_7=1f2335
EOF
    echo "    created    $USER_DIR/PlatypusTokyoNight.conf"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Building resources and dependencies..."

rm -rf build ElyseanShell .cache
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Quickshell configured successfully!"

