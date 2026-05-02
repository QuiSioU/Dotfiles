/* quickshell/widgets/ScreenFrame.qml */


import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: framePanWin

        required property var modelData
        screen: modelData

        anchors {
            top: true;
            right: true;
            bottom: true;
            left: true
        }
        color: "transparent"

        readonly property int gapsOut: 10
        readonly property int gapsOutTop: 25
        readonly property int borderSize: 2
        readonly property int rounding: 15 + borderSize

        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        mask: Region {}

        Rectangle {
            anchors.fill: parent
            color: "#ffffff"

            layer.enabled: true
            layer.effect: MultiEffect {
                maskSource: frameMask
                maskEnabled: true
                maskInverted: true
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1
            }

            Item {
                id: frameMask
                anchors.fill: parent
                layer.enabled: true
                visible: false

                Rectangle {
                    anchors {
                        fill: parent;
                        topMargin: framePanWin.gapsOutTop;
                        leftMargin: framePanWin.gapsOut;
                        rightMargin: framePanWin.gapsOut;
                        bottomMargin: framePanWin.gapsOut
                    }
                    radius: framePanWin.rounding
                }
            }
        }
    }
}
