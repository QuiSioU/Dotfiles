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

if [ -f "$USER_DIR/qmldir" ]; then
    echo "    skipped    $USER_DIR/qmldir: file already exists"
else
    cat > "$USER_DIR/qmldir" <<EOF
# quickshell/themes/user/qmldir


# (Must have at least 1 theme so QML detects this as directory)

PlatypusTokyoNight 1.0 PlatypusTokyoNight.qml
# Rest of custom themes...

EOF
    echo "    created    $USER_DIR/qmldir"
fi

if [ -f "$USER_DIR/PlatypusTokyoNight.qml" ]; then
    echo "    skipped    $USER_DIR/PlatypusTokyoNight.qml: file already exists"
else
    cat > "$USER_DIR/PlatypusTokyoNight.qml" <<EOF
// quickshell/themes/user/PlatypusTokyoNight.qml


import QtQuick

QtObject {
    readonly property string wallpaper: Qt.resolvedUrl("../../assets/wallpapers/Platypus.jpg")
}

EOF
    echo "    created    $USER_DIR/PlatypusTokyoNight.qml"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Building resources and dependencies..."

rm -rf build ElyseanShell .cache
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Quickshell configured successfully!"

