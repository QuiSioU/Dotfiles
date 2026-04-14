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
# themes/user/qmldir

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
// themes/user/PlatypusTokyoNight.qml

import QtQuick

QtObject {
    readonly property string wallpaper: Qt.resolvedUrl("../../assets/wallpapers/Platypus.jpg")
}

EOF
    echo "    created    $USER_DIR/PlatypusTokyoNight.qml"
fi

if [ -f "$THEME_DIR/ActiveTheme.qml" ]; then
    echo "    skipped    $THEME_DIR/ActiveTheme.qml: file already exists"
else
    cat > "$THEME_DIR/ActiveTheme.qml" <<EOF
// themes/ActiveTheme.qml

import QtQuick
import Quickshell
import Quickshell.Wayland
import "default"
import "user"

PanelWindow {
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true;
        bottom: true;
        left: true;
        right: true
    }

    // to change theme, swap "WitcherTokyoNight" → "MyTheme" (located in themes/user, imported above)
    WitcherTokyoNight {
        id: theme
    }

    Image {
        anchors.fill: parent
        source: theme.wallpaper
        fillMode: Image.PreserveAspectCrop
    }
}

EOF
    echo "    created    $THEME_DIR/ActiveTheme.qml"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Building resources and dependencies..."

if [ -d "build" ]; then
    echo "    skipped    $ROOT_DIR/build: directory already exists"
else
    cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    cmake --build build
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Quickshell configured successfully!"

