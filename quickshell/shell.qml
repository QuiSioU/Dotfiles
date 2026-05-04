/* quickshell/shell.qml */


import QtQuick
import Quickshell
import Quickshell.Hyprland
import ElyseanShell.Services
import "./widgets"

ShellRoot {
    settings.watchFiles: true

    Loader { source: "widgets/ThemeLoader.qml" }

    ScreenFrame {}
    Wallpaper {}

    Loader {
        id: globalLauncherLoader
        active: true
        source: "widgets/GlobalLauncher.qml"
    }

    Loader {
        id: sessionMenuLoader
        active: true
        source: "widgets/SessionMenu.qml"
    }

    Loader {
        id: systemMenuLoader
        active: true
        source: "widgets/SystemMenu.qml"
    }

    Loader {
        active: true
        source: "widgets/NotificationDisplay.qml"
    }

    GlobalShortcut {
        name: "toggleGlobalLauncher"
        description: "Toggle Global launcher"
        onPressed: {
            var launcher = globalLauncherLoader.item
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
        name: "toggleSystemMenu"
        description: "System orbit menu"
        onPressed: {
            var orbit = systemMenuLoader.item
            if (!orbit) return

            if (!orbit.visible) {
                orbit._pendingShow = true
                CursorPosition.update()
            } else {
                orbit.closeMenu()
            }
        }
    }

    Connections {
        target: CursorPosition
        function onReady() {
            var donut = sessionMenuLoader.item
            var orbit = systemMenuLoader.item

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
