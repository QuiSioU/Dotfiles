/* quickshell/shell/widgets/TopBar.qml */


import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Wayland

PanelWindow {
    id: root
    readonly property int topbarHeight: 40

    implicitWidth: screen.width
    implicitHeight: screen.height
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: topbarHeight

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: controlPill.pillWidget === "clock" || controlPill.pillWidget === "volume"
        ? WlrKeyboardFocus.None
        : WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "top-bar"

    mask: Region {
        item: controlPill
        Region { item: workspacePill }
    }

    anchors { top: true; right: true; left: true }
    color: "transparent"
    
    focusable: true

    // ── Content ───────────────────────────────────────────────────────────────
    ControlPill {
        id: controlPill
        targetScreen: root.screen
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: (root.topbarHeight - controlPill.clockHeight) / 2
        }
        cornerRadius: root.topbarHeight / 2
    }

    WorkspacePill {
        id: workspacePill
        anchors {
            top: parent.top
            left: parent.left
            leftMargin: screen.width / 10
            topMargin: (root.topbarHeight - workspacePill.height) / 2
        }
        cornerRadius: root.topbarHeight / 2
    }

    function toggleLauncher(): void { controlPill.toggleLauncher() }
    function lockSession(): void { controlPill.lockSession() }
    function reset(): void { controlPill.reset() }
}
