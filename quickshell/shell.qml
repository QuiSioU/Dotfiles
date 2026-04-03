// shell.qml


import Quickshell
import Quickshell.Hyprland
import QtQuick

ShellRoot {
    Loader {
        id: appLauncherLoader
        active: true
        source: "widgets/Launcher/AppLauncher.qml"
    }

    Loader {
        id: bluetoothLauncherLoader
        active: true
        source: "widgets/Launcher/BluetoothLauncher.qml"
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
}