#!/usr/bin/env bash
# hypr/setup.sh


flag_force=false
while getopts "f" opt; do
    case "$opt" in
        f) flag_force=true ;;
        *) echo "Usage: $0 [-f]"; exit 1 ;;
    esac
done

echo "╔═══════════════════════════════════╗"
echo "║ Setting up hyprland configuration ║"
echo "╚═══════════════════════════════════╝"
echo ""

CONFIG_DIR="$HOME/.config"
ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
USER_DIR="$ROOT_DIR/user"

create_file() {
    local filename="$1"
    local title="$2"
    local filepath="$USER_DIR/$filename"

    if [ -f "$filepath" ]; then
        echo "    skipped    $filepath:  file already exists"
        return
    fi

    cat > "$filepath" <<EOF
-- hypr/user/$filename


----- USER'S CUSTOM $title --------------------------- #

EOF

    echo "    created   $filepath"
}

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

echo "Creating override files in hypr/user/ directory..."

mkdir -p "$USER_DIR"

create_file "env.lua"              "ENVIRONMENT VARIABLES CONFIGURATION"
create_file "variables.lua"        "GENERAL SETTINGS"
create_file "monitors.lua"         "MONITORS CONFIGURATION"
create_file "look_and_feel.lua"    "LOOK AND FEEL CONFIGURATION"
create_file "input.lua"            "INPUT CONFIGURATION"
create_file "keybinds.lua"         "KEYBINDS CONFIGURATION"
create_file "windowrules.lua"      "WINDOW RULES CONFIGURATION"
create_file "autostart.lua"        "AUTO START CONFIGURATION"

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Edit files in $USER_DIR to override defaults."

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Hyprland configured successfully!"
