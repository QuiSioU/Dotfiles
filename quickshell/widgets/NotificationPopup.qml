/* quickshell/widgets/NotificationPopup.qml */


import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../services/Notification"
import "base/notification"

Variants {
    model: Quickshell.screens

    PanelWindow {
        required property var modelData
        screen: modelData

        color:          "transparent"
        focusable:      false
        visible:        NotificationService.notifications.length > 0
        implicitWidth:  380
        implicitHeight: column.implicitHeight + 20

        WlrLayershell.layer:         WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace:     "quickshell-notifications"
        exclusionMode:               ExclusionMode.Ignore

        anchors.top:   true
        anchors.right: true

        ColumnLayout {
            id: column
            anchors {
                top:         parent.top
                right:       parent.right
                topMargin:   12
                rightMargin: 12
            }
            width:   360
            spacing: 8

            Repeater {
                model: ScriptModel {
                    values:     NotificationService.notifications
                    objectProp: "seqId"
                }

                delegate: NotificationCard {
                    required property var modelData
                    entry:            modelData
                    Layout.fillWidth: true
                }
            }
        }
    }
}
