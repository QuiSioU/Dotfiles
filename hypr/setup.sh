#!/bin/bash
# hypr/setup.sh


USER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/user"

create_file() {
    local filename="$1"
    local title="$2"
    local filepath="$USER_DIR/$filename"

    if [ -f "$filepath" ]; then
        echo "    skipped    $filepath:  file already exists"
        return
    fi

    cat > "$filepath" <<EOF
# hypr/user/$filename


# --- USER'S CUSTOM $title --------------------------- #

EOF

    echo "    created   $filepath"
}



echo "╔═══════════════════════════════════╗"
echo "║ Setting up hyprland configuration ║"
echo "╚═══════════════════════════════════╝"
echo ""

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

echo "Hyprland configured successfully!"
echo "Edit files in $USER_DIR to override defaults."

