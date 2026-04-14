#!/bin/bash
# hypr/setup.sh


USER_DIR="$HOME/.config/hypr/user"

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

    echo "  created   $filepath"
    echo "--------------------------------------------------------------------------------------"
}




echo "╔═══════════════════════════════════╗"
echo "║ Setting up hyprland configuration ║"
echo "╚═══════════════════════════════════╝"
echo ""

echo "Creating override files in hypr/user/ directory..."

mkdir -p "$USER_DIR"

create_file "env.conf"              "ENVIRONMENT VARIABLES CONFIGURATION"
create_file "variables.conf"        "GENERAL SETTINGS"
create_file "monitors.conf"         "MONITORS CONFIGURATION"
create_file "look-and-feel.conf"    "LOOK AND FEEL CONFIGURATION"
create_file "input.conf"            "INPUT CONFIGURATION"
create_file "keybinds.conf"         "KEYBINDS CONFIGURATION"
create_file "windowrules.conf"      "WINDOW RULES CONFIGURATION"
create_file "autostart.conf"        "AUTO START CONFIGURATION"

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Hyprland configured successfully!"
echo "Edit files in $USER_DIR to override defaults."

