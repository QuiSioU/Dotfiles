#!/bin/bash
# bash/setup.sh


echo "╔═══════════════════════════════╗"
echo "║ Setting up bash configuration ║"
echo "╚═══════════════════════════════╝"
echo ""

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo "Creating user scripts directory structure..."

mkdir -p "$ROOT_DIR/user"
private_script="$ROOT_DIR/user/bash_private.sh"

if [ -L "$private_script" ]; then
    echo "    skipped    $ROOT_DIR/$private_script: file already exists (symlink)"
elif [ -e "$private_script" ]; then
    echo "    skipped    $ROOT_DIR/$private_script: file already exists (not symlink)"
else
    cat > "$private_script" <<EOF
#!/bin/bash
# bash/bash_private.sh


# Place your private stuff here...

EOF
    echo "    created    $private_script"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"


echo "Linking main scripts..."

shopt -s nullglob
for bash_file in "$HOME"/.config/bash/bash*.sh; do
    filename=$(basename "$bash_file")
    target="$HOME/.${filename%.sh}"

    if [ -L "$target" ]; then
        echo "    skipped    $target: file already exists (symlink)"
    elif [ -e "$target" ]; then
        echo "    skipped    $target: file already exists (not symlink)"
    else
        ln -s "$bash_file" "$target"
        echo "    linked     $bash_file -> $target"
    fi
done
shopt -u nullglob

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Bash configured successfully!"
