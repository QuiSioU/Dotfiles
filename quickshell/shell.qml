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
        target: "toggleSessionMenu"
        function handle(): void {
            if (!sessionMenuLoader.active)
                sessionMenuLoader.active = true
            var donut = sessionMenuLoader.item
            if (!donut) return
            if (!donut.visible)
                donut.visible = true
            else
                donut.visible = false
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
                orbit.visible = true
            else {
                orbit.closeMenu()
                systemMenuDestroyTimer.start()
            }
        }
    }
}
