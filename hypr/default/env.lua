-- hypr/default/env.lua


----- ENVIRONMENT VARIABLES -------------------------------------------

hl.env("HYPRCURSOR_SIZE", 24)
hl.env("HYPRSHOT_DIR", os.getenv("HOME") .. "/Pictures/Screenshots")

hl.env("STARSHIP_CONFIG", os.getenv("HOME") .. "/.config/starship/starship.toml")
hl.env("QML_IMPORT_PATH", os.getenv("HOME") .. "/.config/quickshell/.build/qml")
