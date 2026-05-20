-- hypr/default/autostart.lua


----- AUTO START CONFIGURATION -----------------------------

hl.on("hyprland.start", function()
    -- Stuff for screensharing
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- Top bar (temporary until quickshell replacement)
    hl.exec_cmd("eww open topbar")

    -- Wallpaper daemon
    hl.exec_cmd('sh -c "mkdir -p $AWWW_CACHE_HOME && XDG_CACHE_HOME=$AWWW_CACHE_HOME awww-daemon"')

    -- Shell
    hl.exec_cmd("quickshell")
end)
