/* shell.qml */

import Quickshell
import Quickshell.Hyprland
import QtQuick
import ElyseanShell.Services

ShellRoot {
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
        description: "Session pie menu"
        onPressed: {
            var pie = sessionMenuLoader.item
            if (!pie) return

            if (!pie.visible) {
                CursorPosition.update()
            } else {
                pie.visible = false
            }
        }
    }

    Connections {
        target: CursorPosition
        function onReady() {
            var pie = sessionMenuLoader.item
            if (!pie) return
            if (!pie.visible) pie.visible = true
        }
    }
}
