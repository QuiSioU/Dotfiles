/* quickshell/widgets/TopBar.qml */


import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Wayland
import ElysianShell.Services
import ElysianShell.Themes
import "base"

PanelWindow {
    id: root
    readonly property int topbarHeight: 40

    implicitWidth: screen.width
    implicitHeight: screen.height
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: topbarHeight

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: currentMode === "clock" ? WlrKeyboardFocus.None : WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "top-bar"

    mask: Region { item: mainPill }

    anchors { top: true; right: true; left: true }
    color: "transparent"
    focusable: true

    property string currentMode: "clock"

    // ── Possible Menus ────────────────────────────────────────────────────────
    Component {
        id: clockMenu;
        Item {
            id: clockRoot
            implicitWidth: clock.implicitWidth + 32
            implicitHeight: clock.implicitHeight + 12

            Text {
                id: clock
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: 20
                font.bold: true
                text: Qt.formatTime(new Date(), "hh:mm")
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: clock.text = Qt.formatTime(new Date(), "hh:mm")
                }
            }
        }
    }
    Component {
        id: lockDecoy
        LockVisual {
            implicitWidth: screen.width
            implicitHeight: screen.height
            wallpaper: LockService.currentWallpaper   // shared source, see note below
        }
    }

    LockScreen {
        id: lockScreen
    }

    onCurrentModeChanged: {
        switch (currentMode) {
            case "lock": mainPill.content = lockDecoy; break
            default:     mainPill.content = clockMenu; break
        }
    }
    Component.onCompleted: mainPill.content = clockMenu

    // ── Morph handoff ────────────────────────────────────────────────────
    Connections {
        target: mainPill
        function onMorphFinished() {
            if (root.currentMode === "lock" && !lockScreen.isLocked) {
                mainPill.square = true
                lockScreen.lock()   // decoy is fully fullscreen now — safe to hand off
            }
        }
    }

    Connections {
        target: lockScreen
        function onReadyToUnlock() {
            mainPill.square = false
            lockScreen.unlock()      // decoy still fullscreen underneath — no flash
            root.currentMode = "clock"    // now shrink back down
        }
    }

    // ── Content ───────────────────────────────────────────────────────────────
    MorphingPill {
        id: mainPill
        color: ActiveTheme.colors["BG"]
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: root.topbarHeight / 10
        }
        cornerRadius: root.topbarHeight / 2
    }

    IpcHandler {
        target: "topbar"
        function openLauncher(): void { root.currentMode = "launcher" }
        function lockSession(): void { root.currentMode = "lock" }
        function reset(): void { root.currentMode = "clock" }
    }
}
