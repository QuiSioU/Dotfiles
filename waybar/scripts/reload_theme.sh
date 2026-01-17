#!/bin/bash

WAYBAR_DIR="$HOME/.config/waybar"
CSS_FILE="$WAYBAR_DIR/style.css"
THEME_FILE_PILL_CIRCLES="$WAYBAR_DIR/themes/theme_pill_circles.css"
THEME_FILE_FULL_CIRCLES="$WAYBAR_DIR/themes/theme_full_circles.css"

CONFIG_FILE="$WAYBAR_DIR/config.jsonc"
CONFIG_FILE_MAIN="$WAYBAR_DIR/configs/config1.jsonc"

# Función para verificar a qué apunta el enlace actual
get_current_theme() {
    if [ -L "$CONFIG_FILE" ]; then
        current_config_target=$(readlink -f "$CONFIG_FILE")
        if [ "$current_config_target" = "$CONFIG_FILE_MAIN"]; then
        echo "nada"
        else
          ln -sf "$CONFIG_FILE_MAIN" "$CONFIG_FILE"
        fi
    fi
    if [ -L "$CSS_FILE" ]; then
        current_target=$(readlink -f "$CSS_FILE")
        if [ "$current_target" = "$THEME_FILE_PILL_CIRCLES" ]; then
            echo "theme_pill_circles"
        elif [ "$current_target" = "$THEME_FILE_FULL_CIRCLES" ]; then
            echo "theme_full_circles"
        else
            echo "unknown"
        fi
    else
        echo "not_linked"
    fi
}

# Función para alternar temas
reload_current_theme() {
    current=$(get_current_theme)
    echo "Esto es la prueba con $current"
    
    case $current in
        "theme_pill_circles")
            ln -sf "$THEME_FILE_PILL_CIRCLES" "$CSS_FILE"
            ;;
        "theme_full_circles")
            ln -sf "$THEME_FILE_FULL_CIRCLES" "$CSS_FILE"
            ;;
        "not_linked"|"unknown")
            ln -sf "$THEME_FILE_PILL_CIRCLES" "$CSS_FILE"
            ;;
    esac
    
    restart_waybar
}

# Función para reiniciar waybar
restart_waybar() {
    pkill waybar || true
    waybar &
}

reload_current_theme
