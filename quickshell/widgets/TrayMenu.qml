/* quickshell/widgets/TrayMenu.qml */

import QtQuick
import Quickshell.Services.Pipewire
import Quickshell.Io
import "base/orbit"

OrbitMenu {
    entries: [
        {
            name: "Logout",
            icon: "system-log-out",
            action: () => logout.running = true
        },
        {
            name: "Reboot",
            icon: "system-reboot",
            action: () => reboot.running = true
        },
        {
            name: "Shutdown",
            icon: "system-shutdown",
            action: () => shutdown.running = true
        }
    ]

    Process {
        id: shutdown
        command: ["systemctl", "poweroff"]
        running: false
    }

    Process {
        id: reboot
        command: ["systemctl", "reboot"]
        running: false
    }

    Process {
        id: logout
        command: ["hyprctl", "dispatch", "exit"]
        running: false
    }
}
