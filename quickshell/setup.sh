#!/bin/bash
# quickshell/setup.sh


echo "╔═════════════════════════════════════╗"
echo "║ Setting up quickshell configuration ║"
echo "╚═════════════════════════════════════╝"
echo ""

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

THEME_DIR="$ROOT_DIR/themes"
USER_DIR="$THEME_DIR/user"

mkdir -p "$USER_DIR"

echo "Creating directory structure for user's custom themes..."

if [ -f "$USER_DIR/PlatypusTokyoNight.conf" ]; then
    echo "    skipped    $USER_DIR/PlatypusTokyoNight.conf: file already exists"
else
    cat > "$USER_DIR/PlatypusTokyoNight.conf" <<EOF
# quickshell/themes/default/PlatypusTokyoNight.conf


WALLPAPER_PATH=~/.config/quickshell/assets/wallpapers/Platypus.jpg

# Base UI
BG=rgba(1a1b26ff)
BG_DARK=rgba(16161eff)
BG_HIGHLIGHT=rgba(292e42ff)
TERMINAL_BLACK=rgba(414868ff)
FG=rgba(c0caf5ff)
FG_DARK=rgba(a9b1d6ff)
FG_GUTTER=rgba(3b4261ff)
DARK3=rgba(545c7eff)
DARK5=rgba(737aa2ff)
COMMENT=rgba(565f89ff)

# Syntax / Accent
BLUE=rgba(7aa2f7ff)
CYAN=rgba(7dcfffff)
BLUE1=rgba(2ac3deff)
BLUE2=rgba(0db9d7ff)
BLUE5=rgba(89ddffff)
BLUE6=rgba(b4f9f8ff)
BLUE7=rgba(394b70ff)
MAGENTA=rgba(bb9af7ff)
MAGENTA2=rgba(ff007cff)
PURPLE=rgba(9d7cd8ff)
ORANGE=rgba(ff9e64ff)
YELLOW=rgba(e0af68ff)
GREEN=rgba(9ece6aff)
GREEN1=rgba(73dacaff)
GREEN2=rgba(41a6b5ff)
TEAL=rgba(1abc9cff)
RED=rgba(f7768eff)
RED1=rgba(db4b4bff)
EOF
    echo "    created    $USER_DIR/PlatypusTokyoNight.conf"
fi

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Building resources and dependencies..."

rm -rf .build ElyseanShell .cache
bash "$ROOT_DIR/build.sh"

echo "╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌"

echo "Quickshell configured successfully!"

