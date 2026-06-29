#!/bin/sh
# quickshell/setup.sh


flag_force=false
while getopts "f" opt; do
    case "$opt" in
        f) flag_force=true ;;
        *) echo "Usage: $0 [-f]"; exit 1 ;;
    esac
done

echo "╔═════════════════════════════════════╗"
echo "║ Setting up quickshell configuration ║"
echo "╚═════════════════════════════════════╝"
echo ""

CONFIG_DIR="$HOME/.config"
ROOT_DIR=$(cd "$(dirname "$0")" && pwd)
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

if [ "$flag_force" = true ]; then
    rm -rf .build .cache
fi

cmake -B .build -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build .build --parallel

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Creating default quick apps list..."

userDir="widgets/user"

if [ -L "$userDir" ]; then
    echo "    skipped    $userDir: file already exists (symlink)"
elif [ -e "$userDir" ]; then
    echo "    skipped    $userDir: file already exists (not symlink)"
else
    mkdir -p "$userDir"
    echo "    created    $userDir"
fi

quickAppsListfile="$userDir/QuickAppsList.qml"

if [ -L "$quickAppsListfile" ]; then
    echo "    skipped    $quickAppsListfile: file already exists (symlink)"
elif [ -e "$quickAppsListfile" ]; then
    echo "    skipped    $quickAppsListfile: file already exists (not symlink)"
else
    cat > $quickAppsListfile <<EOF
// quickshell/$quickAppsListfile


pragma Singleton
import Quickshell

Singleton {
    // Add here your favourite apps (by their .desktop filename) to add them to quick access
    readonly property list<string> apps: [
        "codium",
        "firefox",
        "steam"
    ]
}
EOF
    echo "    created    $quickAppsListfile"
fi

qumldirfile="$userDir/qmldir"

if [ -L "$qumldirfile" ]; then
    echo "    skipped    $qumldirfile: file already exists (symlink)"
elif [ -e "$qumldirfile" ]; then
    echo "    skipped    $qumldirfile: file already exists (not symlink)"
else
    cat > $qumldirfile <<EOF
# quickshell/$qumldirfile


singleton QuickAppsList 1.0 QuickAppsList.qml
EOF
    echo "    created    $qumldirfile"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Quickshell configured successfully!"
