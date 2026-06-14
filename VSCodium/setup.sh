#!/usr/bin/env bash
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
ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$ROOT_DIR"

echo "Setting up configuration files..."

for file in "$ROOT_DIR"/config/*; do
    file="${file%/}"
    target="$CONFIG_DIR/VSCodium/User/$(basename "$file")"

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

for file in "$HOME"/.config/elysian_themes/themes/default/*; do
    python3 build_themes.py "$file" "$COLOR_THEMES_DIR"
done

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
    python3 build_package.py
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

if [ ! -f /etc/NIXOS ]; then
    echo "Setting up custom user extensions..."

    while IFS= read -r extension; do
        [[ -z "$extension" || "$extension" == \#* ]] && continue
        if codium --list-extensions | grep -q "^$extension$"; then
            echo "    skipped    $extension: extension already installed"
        else
            codium --install-extension "$extension"
        fi
    done < "$ROOT_DIR/extensions.txt"

    echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"
fi

echo "VSCodium configured successfully!"
