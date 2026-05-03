/* quickshell/widgets/ScreenFrame.qml */


import QtQuick
import Quickshell
import Quickshell.Wayland
import ElyseanShell.Services
import ElyseanShell.Themes

Variants {
    model: Quickshell.screens

    Scope {
        id: scope
        required property var modelData

        readonly property color frameColor:         ActiveTheme.color["BG"]
        readonly property int   rounding:           33
        readonly property int   thicknessTop:       30
        readonly property int   thicknessBottom:    10
        readonly property int   thicknessLeft:      10
        readonly property int   thicknessRight:     10
        readonly property int   borderSize:         0
        readonly property real  shadowSize:         5
        readonly property int   shadowOpacity:      127

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

        EdgeZone { anchors.top: true;    exclusiveZone: scope.thicknessTop }
        EdgeZone { anchors.bottom: true; exclusiveZone: scope.thicknessBottom }
        EdgeZone { anchors.left: true;   exclusiveZone: scope.thicknessLeft }
        EdgeZone { anchors.right: true;  exclusiveZone: scope.thicknessRight }

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
                anchors.fill:       parent
                color:              scope.frameColor
                radius:             scope.rounding
                thicknessTop:       scope.thicknessTop
                thicknessBottom:    scope.thicknessBottom
                thicknessLeft:      scope.thicknessLeft
                thicknessRight:     scope.thicknessRight
                borderSize:         scope.borderSize
                shadowSize:         scope.shadowSize
                shadowOpacity:      scope.shadowOpacity
            }
        }
    }
}
