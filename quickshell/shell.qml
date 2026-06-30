/* quickshell/shell.qml */


import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root

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
        id: quickAppsMenuLoader
        active: false
        source: "widgets/QuickAppsMenu.qml"
        visible: false

        onItemChanged: {
            if (item) item.menuClosed.connect(
                () => quickAppsMenuLoader.active = false
            )
        }
    }

    Loader {
        active: true
        source: "widgets/NotificationDisplay.qml"
    }

    function closeOtherMenus(exceptLoader) {
        if (exceptLoader !== controlCenterLoader && controlCenterLoader.item?.visible)
            controlCenterLoader.item.close()
        if (exceptLoader !== systemMenuLoader && systemMenuLoader.item?.visible)
            systemMenuLoader.item.closeMenu()
        if (exceptLoader !== trayMenuLoader && trayMenuLoader.item?.visible)
            trayMenuLoader.item.closeMenu()
        if (exceptLoader !== quickAppsMenuLoader && quickAppsMenuLoader.item?.visible)
            quickAppsMenuLoader.item.closeMenu()
    }

    IpcHandler {
        target: "toggleControlCenter"
        function handle(): void {
            if (!controlCenterLoader.active)
                controlCenterLoader.active = true

            var launcher = controlCenterLoader.item
            if (!launcher) return

            if (!launcher.visible) {
                root.closeOtherMenus(controlCenterLoader)
                launcher.visible = true
            }
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
            if (!orbit.visible) {
                root.closeOtherMenus(systemMenuLoader)
                orbit.openMenu()
            }
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
            if (!orbit.visible) {
                root.closeOtherMenus(trayMenuLoader)
                orbit.openMenu()
            }
            else {
                orbit.closeMenu()
            }
        }
    }

    IpcHandler {
        target: "toggleQuickAppsMenu"
        function handle(): void {
            if (!quickAppsMenuLoader.active)
                quickAppsMenuLoader.active = true
            var orbit = quickAppsMenuLoader.item
            if (!orbit) return
            if (!orbit.visible) {
                root.closeOtherMenus(quickAppsMenuLoader)
                orbit.openMenu()
            }
            else {
                orbit.closeMenu()
            }
        }
    }
}
