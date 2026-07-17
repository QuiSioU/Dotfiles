#!/bin/sh
# quickshell/shell/setup.sh


flag_force=false
while getopts "fn" opt; do
    case "$opt" in
        f) flag_force=true ;;
        n) ;;
        *) echo "Usage: $0 [-f]"; exit 1 ;;
    esac
done

echo "╔═════════════════════════════════════╗"
echo "║ Setting up quickshell configuration ║"
echo "╚═════════════════════════════════════╝"
echo ""

CONFIG_DIR="$HOME/.config"
ROOT_DIR=$(cd "$(dirname "$0")" && pwd)
SHELL_DIR="$ROOT_DIR/shell"
VESKTOP_OVERLAY_DIR="$ROOT_DIR/vesktop-overlay"
cd "$ROOT_DIR"

echo "Creating symlink in $CONFIG_DIR..."

symlink_src="${ROOT_DIR%/}"
symlink_dst="$CONFIG_DIR/$(basename "$symlink_src")"

if [ "$flag_force" = true ]; then
    rm -f "$symlink_dst"
fi

if [ -L "$symlink_dst" ]; then
    echo "    skipped    $symlink_dst: file already exists (symlink)"
elif [ -e "$symlink_dst" ]; then
    echo "    skipped    $symlink_dst: file already exists (not symlink)"
else
    ln -s "$symlink_src" "$symlink_dst"
    echo "    linked     $symlink_src -> $symlink_dst"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Building resources and dependencies..."

cd "$SHELL_DIR"

if [ "$flag_force" = true ]; then
    rm -rf .build .cache
fi

cmake -B .build -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
if [ $? -ne 0 ]; then
    echo "cmake configure failed, aborting..."
    exit 1
fi

cmake --build .build --parallel
if [ $? -ne 0 ]; then
    echo "cmake build failed, aborting..."
    exit 1
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Creating default quick apps list..."

quickAppsfile="quickapps.json"

if [ -L "$quickAppsfile" ]; then
    echo "    skipped    $quickAppsfile: file already exists (symlink)"
elif [ -e "$quickAppsfile" ]; then
    echo "    skipped    $quickAppsfile: file already exists (not symlink)"
else
    cat > $quickAppsfile <<EOF
[
    "codium",
    "firefox",
    "vesktop",
    "steam"
]
EOF
    echo "    created    $quickAppsfile"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Creating default ignore apps' notifications list..."

ignoreNotificationsFile="ignoreNotifications.json"

if [ -L "$ignoreNotificationsFile" ]; then
    echo "    skipped    $ignoreNotificationsFile: file already exists (symlink)"
elif [ -e "$ignoreNotificationsFile" ]; then
    echo "    skipped    $ignoreNotificationsFile: file already exists (not symlink)"
else
    cat > $ignoreNotificationsFile <<EOF
[
    "OpenRazer"
]
EOF
    echo "    created    $ignoreNotificationsFile"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Ensuring scripts are executable..."

[ -d scripts ] && chmod +x scripts/*

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Quickshell configured successfully!"

cd "$ROOT_DIR"
