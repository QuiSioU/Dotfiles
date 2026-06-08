/* quickshell/shell.qml */


import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    Loader {
        source: "widgets/ThemeLoader.qml"
    }

    Loader {
        id: controlCenterLoader
        active: false
        source: "widgets/ControlCenter.qml"
        visible: false
    }

    Loader {
        id: systemMenuLoader
        active: false
        source: "widgets/SystemMenu.qml"
        visible: false

        onItemChanged: {
            if (item) item.menuClosed.connect(
                () => systemMenuLoader.active = false
            )
        }
    }

    Loader {
        id: trayMenuLoader
        active: false
        source: "widgets/TrayMenu.qml"
        visible: false

        onItemChanged: {
            if (item) item.menuClosed.connect(
                () => trayMenuLoader.active = false
            )
        }
    }

    Loader {
        active: true
        source: "widgets/NotificationDisplay.qml"
    }

    IpcHandler {
        target: "toggleControlCenter"
        function handle(): void {
            if (!controlCenterLoader.active)
                controlCenterLoader.active = true

            var launcher = controlCenterLoader.item
            if (!launcher) return

            if (!launcher.visible)
                launcher.visible = true
            else
                launcher.close()
        }
    }

    IpcHandler {
        target: "toggleSystemMenu"
        function handle(): void {
            if (!systemMenuLoader.active)
                systemMenuLoader.active = true
            var orbit = systemMenuLoader.item
            if (!orbit) return
            if (!orbit.visible)
                orbit.openMenu()
            else {
                orbit.closeMenu()
            }
        }
    }

    IpcHandler {
        target: "toggleTrayMenu"
        function handle(): void {
            if (!trayMenuLoader.active)
                trayMenuLoader.active = true
            var orbit = trayMenuLoader.item
            if (!orbit) return
            if (!orbit.visible)
                orbit.openMenu()
            else {
                orbit.closeMenu()
            }
        }
    }
}
