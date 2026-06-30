#!/bin/sh
# quickshell/setup.sh


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

echo "Quickshell configured successfully!"
