#!/bin/bash

# quickshell/setup.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [ -d "build" ]; then
    echo "  skipped   "build" (directory already exists)"
else
    cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    cmake --build build
fi

HYPR_DIR="$HOME/.config/hypr"
USER_DIR="$ROOT_DIR/themes/user"

mkdir -p "$USER_DIR"

if [ -f "$USER_DIR/qmldir" ]; then
    echo "  skipped   "$USER_DIR/qmldir" (already exists)"
else
    cat > "$USER_DIR/qmldir" <<EOF
# themes/user/qmldir

Foo 1.0 Foo.qml # Remove when created at least one custom theme
# Rest of custom themes...

EOF
fi

if [ -f "$USER_DIR/Foo.qml" ]; then
    echo "  skipped   "$USER_DIR/Foo.qml" (already exists)"
else
    cat > "$USER_DIR/Foo.qml" <<EOF
// themes/user/Foo.qml

import QtQuick

QtObject {
    readonly property string wallpaper: Qt.resolvedUrl("../../assets/wallpapers/Platypus.jpg")
}

EOF
fi