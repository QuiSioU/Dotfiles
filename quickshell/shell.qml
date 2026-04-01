// shell.qml


import Quickshell
import Quickshell.Hyprland
import QtQuick

ShellRoot {
    Loader {
        id: launcherLoader
        active: true
        source: "widgets/Launcher/AppLauncher.qml"
    }

    GlobalShortcut {
        name: "toggleLauncher"
        description: "Toggle app launcher"
        onPressed: {
            var launcher = launcherLoader.item
            if (launcher) launcher.visible = !launcher.visible
        }
    }
}