import QtQuick
import Quickshell.Hyprland
import ElysianShell.Themes
import "base"

MorphingPill {
    id: root
    color: ActiveTheme.colors["FG"]

    property int _radius: 15

    Component {
        id: workspaceComponent

        Item {
            id: contentRoot
            property real horizontalPadding: 8
            property real verticalPadding: 4

            implicitWidth: row.implicitWidth + horizontalPadding * 2
            implicitHeight: row.implicitHeight + verticalPadding * 2

            Row {
                id: row
                anchors.centerIn: parent
                spacing: 6

                Repeater {
                    model: 5

                    Rectangle {
                        id: wsIndicator
                        required property int index

                        readonly property int workspaceId: index + 1
                        readonly property bool active: Hyprland.focusedWorkspace?.id === workspaceId

                        width: root._radius
                        height: root._radius
                        radius: width / 2
                        color: active ? ActiveTheme.colors["ANSI_BLUE"] : ActiveTheme.colors["ANSI_RED"]

                        Behavior on color { ColorAnimation { duration: 150 } }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + wsIndicator.workspaceId + " })")
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: root.content = workspaceComponent
}
