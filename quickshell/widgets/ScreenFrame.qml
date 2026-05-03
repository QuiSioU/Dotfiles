/* quickshell/widgets/ScreenFrame.qml */


import QtQuick
import Quickshell
import Quickshell.Wayland
import ElyseanShell.Services

Variants {
    model: Quickshell.screens

    Scope {
        id: scope
        required property var modelData

        readonly property int    thickness: 10
        readonly property int    rounding:  25
        readonly property color  frameColor: "#1e1e2e"

        // ── 1. Exclusion zones — push windows inward ──────────────────
        component EdgeZone: PanelWindow {
            screen: scope.modelData
            exclusiveZone: scope.thickness
            color: "transparent"
            mask: Region {}
            implicitWidth: 1
            implicitHeight: 1
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        }

        EdgeZone { anchors.top: true }
        EdgeZone { anchors.bottom: true }
        EdgeZone { anchors.left: true }
        EdgeZone { anchors.right: true }

        // ── 2. Full-screen overlay — SDF frame drawn by C++ item ──────
        PanelWindow {
            screen: scope.modelData
            color: "transparent"
            anchors.top: true; anchors.bottom: true
            anchors.left: true; anchors.right: true
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            mask: Region {}

            ScreenFrameItem {
                anchors.fill: parent
                color:     scope.frameColor
                radius:    scope.rounding
                thickness: scope.thickness
            }
        }
    }
}
