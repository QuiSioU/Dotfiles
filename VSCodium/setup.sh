#!/bin/sh
# VSCodium/setup.sh


flag_force=false
while getopts "f" opt; do
    case "$opt" in
        f) flag_force=true ;;
        *) echo "Usage: $0 [-f]"; exit 1 ;;
    esac
done

echo "╔═══════════════════════════════════╗"
echo "║ Setting up VSCodium configuration ║"
echo "╚═══════════════════════════════════╝"
echo ""

CONFIG_DIR="$HOME/.config"
ROOT_DIR=$(cd "$(dirname "$0")" && pwd)

echo "Setting up configuration files..."

CODIUM_USER_DIR="$CONFIG_DIR/VSCodium/User"
mkdir -p "$CODIUM_USER_DIR"

for file in "$ROOT_DIR"/config/*; do
    file="${file%/}"
    target="$CODIUM_USER_DIR/$(basename "$file")"

    if [ "$flag_force" = true ]; then
        rm -rf "$target"
    fi

    if [ -L "$target" ]; then
        echo "    skipped    $target: file already exists (symlink)"
    elif [ -e "$target" ]; then
        echo "    skipped    $target: file already exists (not symlink)"
    else
        ln -s "$file" "$target"
        echo "    linked     $file -> $target"
    fi
done

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Setting up color themes..."

COLOR_THEMES_DIR="$ROOT_DIR/themes/"
mkdir -p "$COLOR_THEMES_DIR"

THEME_SRC_DIR="$CONFIG_DIR/elysian_themes/themes/default"
if [ -d "$THEME_SRC_DIR" ]; then
    for file in "$THEME_SRC_DIR"/*; do
        [ -e "$file" ] || continue
        python3 "$ROOT_DIR/build_themes.py" "$file" "$COLOR_THEMES_DIR"
    done
else
    echo "    warning    Theme source directory missing: $THEME_SRC_DIR"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Creating color theme extension package file..."

PACKAGE_FILE="$ROOT_DIR/package.json"

if [ "$flag_force" = true ]; then
    rm -rf "$PACKAGE_FILE"
fi

if [ -L "$PACKAGE_FILE" ]; then
    echo "    skipped    $PACKAGE_FILE: file already exists (symlink)"
elif [ -e "$PACKAGE_FILE" ]; then
    echo "    skipped    $PACKAGE_FILE: file already exists (not symlink)"
else
    python3 "$ROOT_DIR/build_package.py"
    echo "    created    $PACKAGE_FILE"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Setting up vscodium global color theme extension directory..."

EXTENSION_DIR="$HOME/.vscode-oss/extensions/quisiou.elysian-color-themes-universal"
mkdir -p "$EXTENSION_DIR"

for file in "$COLOR_THEMES_DIR" "$PACKAGE_FILE"; do
    file="${file%/}"
    target="$EXTENSION_DIR/$(basename "$file")"

    if [ "$flag_force" = true ]; then
        rm -rf "$target"
    fi

    if [ -L "$target" ]; then
        echo "    skipped    $target: file already exists (symlink)"
    elif [ -e "$target" ]; then
        echo "    skipped    $target: file already exists (not symlink)"
    else
        ln -s "$file" "$target"
        echo "    linked     $file -> $target"
    fi
done

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "VSCodium configured successfully!"
