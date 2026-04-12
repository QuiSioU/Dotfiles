#!/bin/bash

# hypr/setup.sh

# Generates the user/ directory with empty override files
# Run this once after cloning the dotfiles repo

USER_DIR="$HOME/.config/hypr/user"

mkdir -p "$USER_DIR"

create_file() {
    local filename="$1"
    local title="$2"
    local filepath="$USER_DIR/$filename"

    if [ -f "$filepath" ]; then
        echo "  skipped   $filepath (already exists)"
        return
    fi

    cat > "$filepath" <<EOF
# user/$filename



# --- USER'S CUSTOM $title --------------------------- #

EOF

    echo "  created   $filepath"
}

echo "Setting up user/ overrides in $USER_DIR..."
echo ""

create_file "env.conf"              "ENVIRONMENT VARIABLES CONFIGURATION"
create_file "variables.conf"        "GENERAL SETTINGS"
create_file "monitors.conf"         "MONITORS CONFIGURATION"
create_file "look-and-feel.conf"    "LOOK AND FEEL CONFIGURATION"
create_file "input.conf"            "INPUT CONFIGURATION"
create_file "keybinds.conf"         "KEYBINDS CONFIGURATION"
create_file "windowrules.conf"      "WINDOW RULES CONFIGURATION"
create_file "autostart.conf"        "AUTO START CONFIGURATION"

echo ""
echo "Done! Edit files in $USER_DIR to override defaults."
