/* quickshell/shell.qml */


import QtQuick
import Quickshell
import Quickshell.Hyprland
import ElyseanShell.Services
import "./widgets"

ShellRoot {
    Loader { source: "widgets/ThemeLoader.qml" }

    ScreenFrame {}
    Wallpaper {}

    Loader {
        id: globalLauncherLoader
        active: false
        source: "widgets/GlobalLauncher.qml"
        visible: false
    }

    Loader {
        id: sessionMenuLoader
        active: false
        source: "widgets/SessionMenu.qml"
        visible: false
    }

    Loader {
        id: systemMenuLoader
        active: false
        source: "widgets/SystemMenu.qml"
        visible: false
    }

    Loader {
        active: true
        source: "widgets/NotificationDisplay.qml"
    }

    Timer {
        id: systemMenuDestroyTimer
        interval: 500
        repeat: false
        onTriggered: systemMenuLoader.active = false
    }

    GlobalShortcut {
        name: "toggleGlobalLauncher"
        description: "Toggle Global launcher"
        onPressed: {
            if (!globalLauncherLoader.active) {
                globalLauncherLoader.active = true
            }

            var launcher = globalLauncherLoader.item
            if (launcher) launcher.visible = !launcher.visible
        }
    }

    GlobalShortcut {
        name: "toggleSessionMenu"
        description: "Session donut menu"
        onPressed: {
            if (!sessionMenuLoader.active) {
                sessionMenuLoader.active = true
            }

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
            if (!systemMenuLoader.active) {
                systemMenuLoader.active = true
            }
            
            var orbit = systemMenuLoader.item
            if (!orbit) return

            if (!orbit.visible) {
                orbit._pendingShow = true
                CursorPosition.update()
            } else {
                orbit.closeMenu()
                systemMenuDestroyTimer.start()
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
