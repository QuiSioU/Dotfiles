/* quickshell/shell.qml */


import Quickshell
import Quickshell.Hyprland
import QtQuick
import ElyseanShell.Services
import "./themes"

ShellRoot {
    ThemeLoader {}

    Loader {
        id: appLauncherLoader
        active: true
        source: "widgets/AppLauncher.qml"
    }

    Loader {
        id: bluetoothLauncherLoader
        active: true
        source: "widgets/BluetoothLauncher.qml"
    }

    Loader {
        id: sessionMenuLoader
        active: true
        source: "widgets/SessionMenu.qml"
    }

    Loader {
        id: trayMenuLoader
        active: true
        source: "widgets/TrayMenu.qml"
    }

    GlobalShortcut {
        name: "toggleAppLauncher"
        description: "Toggle App launcher"
        onPressed: {
            var launcher = appLauncherLoader.item
            if (launcher) launcher.visible = !launcher.visible
        }
    }

    GlobalShortcut {
        name: "toggleBluetoothLauncher"
        description: "Toggle Bluetooth launcher"
        onPressed: {
            var launcher = bluetoothLauncherLoader.item
            if (launcher) launcher.visible = !launcher.visible
        }
    }

    GlobalShortcut {
        name: "toggleSessionMenu"
        description: "Session donut menu"
        onPressed: {
            var donut = sessionMenuLoader.item
            if (!donut) return

            if (!donut.visible) {
                donut._pendingShow = true
                CursorPosition.update()
            } else {
                donut.visible = false
            }
        }
    }

    GlobalShortcut {
        name: "toggleTrayMenu"
        description: "Tray orbit menu"
        onPressed: {
            var orbit = trayMenuLoader.item
            if (!orbit) return

            if (!orbit.visible) {
                orbit._pendingShow = true
                CursorPosition.update()
            } else {
                orbit.visible = false
            }
        }
    }

    Connections {
        target: CursorPosition
        function onReady() {
            var donut = sessionMenuLoader.item
            var orbit = trayMenuLoader.item

            // Only show whichever was just requested, not both
            if (donut && donut._pendingShow) {
                donut._pendingShow = false
                donut.visible = true
            } else if (orbit && orbit._pendingShow) {
                orbit._pendingShow = false
                orbit.visible = true
            }
        }
    }
}
