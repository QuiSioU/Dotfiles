#!/bin/bash

# quickshell/setup.sh

echo "╔═════════════════════════════════════╗"
echo "║ Setting up quickshell configuration ║"
echo "╚═════════════════════════════════════╝"
echo ""

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo "Building resources and dependencies..."

if [ -d "build" ]; then
    echo "    skipped    $ROOT_DIR/build: directory already exists"
else
    cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    cmake --build build
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

HYPR_DIR="$HOME/.config/hypr"
USER_DIR="$ROOT_DIR/themes/user"

mkdir -p "$USER_DIR"

echo "Creating directory structure for user's custom themes..."

if [ -f "$USER_DIR/qmldir" ]; then
    echo "    skipped    $USER_DIR/qmldir: file already exists"
else
    cat > "$USER_DIR/qmldir" <<EOF
# themes/user/qmldir

Foo 1.0 Foo.qml # Remove when created at least one custom theme
# Rest of custom themes...

EOF
    echo "    created    $USER_DIR/qmldir"
fi

if [ -f "$USER_DIR/Foo.qml" ]; then
    echo "    skipped    $USER_DIR/Foo.qml: file already exists"
else
    cat > "$USER_DIR/Foo.qml" <<EOF
// themes/user/Foo.qml

import QtQuick

QtObject {
    readonly property string wallpaper: Qt.resolvedUrl("../../assets/wallpapers/Platypus.jpg")
}

EOF
    echo "    created    $USER_DIR/Foo.qml"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Quickshell configured successfully!"
