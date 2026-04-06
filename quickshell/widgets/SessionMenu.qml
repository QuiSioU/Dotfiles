/* widgets/SessionMenu.qml */

import QtQuick
import Quickshell.Io
import "base/pie"

PieMenu {
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
