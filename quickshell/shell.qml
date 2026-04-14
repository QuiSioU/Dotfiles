/* shell.qml */

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
                CursorPosition.update()
            } else {
                donut.visible = false
            }
        }
    }

    Connections {
        target: CursorPosition
        function onReady() {
            var donut = sessionMenuLoader.item
            if (!donut) return
            if (!donut.visible) donut.visible = true
        }
    }
}
