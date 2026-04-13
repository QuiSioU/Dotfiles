#!/bin/bash

# bash/setup.sh
echo "╔═══════════════════════════════╗"
echo "║ Setting up bash configuration ║"
echo "╚═══════════════════════════════╝"
echo ""

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo "Creating private scripts..."

priv_scripts=("bash_aliases_priv.sh" "bash_env_priv.sh")
for bash_file in "${priv_scripts[@]}"; do
    if [ -L "$bash_file" ]; then
        echo "    skipped    $ROOT_DIR/$bash_file: file already exists (symlink)"
    elif [ -e "$bash_file" ]; then
        echo "    skipped    $ROOT_DIR/$bash_file: file already exists (not symlink)"
    else
    	cat > "$bash_file" <<EOF
#!/bin/bash

# bash/$bash_file


# Place your private stuff here...

EOF
    echo "    created    $ROOT_DIR/$bash_file"
fi
done

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"


echo "Linking scripts..."

shopt -s nullglob
for bash_file in bash*.sh; do
    target="$HOME/.${bash_file%.sh}"
    if [ -L "$target" ]; then
        echo "    skipped    $target: file already exists (symlink)"
    elif [ -e "$target" ]; then
        echo "    skipped    $target: file already exists (not symlink)"
    else
        ln -s "$HOME/.config/bash/$bash_file" "$target"
        echo "    linked     $HOME/.config/bash/$bash_file -> $target"
    fi
done

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Bash configured successfully!"

