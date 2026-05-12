-- hypr/default/autostart.lua


----- AUTO START CONFIGURATION -----------------------------

hl.on("hyprland.start", function()
    -- Stuff for screensharing
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- Top bar (temporary until quickshell replacement)
    hl.exec_cmd("eww open topbar")

    -- Shell
    hl.exec_cmd("quickshell")
end)
