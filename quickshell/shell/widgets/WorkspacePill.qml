import QtQuick
import Quickshell.Hyprland
import ElysianShell.Themes
import "base"

MorphingPill {
    id: root
    color: ActiveTheme.colors["BG"]

    property int _radius: 15
    property int _animDuration: 100
    property int min_indicators: 5

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
                spacing: 10

                Repeater {
                    model: 10

                    Rectangle {
                        id: wsIndicator
                        required property int index
                        readonly property int workspaceId: index + 1

                        // find the live HyprlandWorkspace object matching this id, if any
                        readonly property var hyprWorkspace: {
                            for (let i = 0; i < Hyprland.workspaces.values.length; i++) {
                                if (Hyprland.workspaces.values[i].id === workspaceId)
                                    return Hyprland.workspaces.values[i];
                            }
                            return null;
                        }
                        readonly property bool active: hyprWorkspace?.focused ?? false
                        visible: workspaceId <= Hyprland.focusedWorkspace?.id || index < root.min_indicators

                        width: active ? root._radius * 3 : root._radius
                        height: root._radius
                        radius: height / 2
                        color: active
                            ? ActiveTheme.colors["SECONDARY"]
                            : hyprWorkspace !== null ? ActiveTheme.colors["WARNING"]
                            : ActiveTheme.colors["FG_HINT"]

                        border {
                            width: 0
                            color: ActiveTheme.colors["FG"]
                        }

                        Behavior on color { ColorAnimation { duration: root._animDuration } }

                        Behavior on width { NumberAnimation {
                            id: widthAnim
                            duration: root._animDuration
                            easing.type: Easing.InOutCubic
                        }}

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true

                            onEntered: wsIndicator.border.width = 2
                            onExited: wsIndicator.border.width = 0
                            onClicked: {
                                if (wsIndicator.hyprWorkspace) wsIndicator.hyprWorkspace.activate()
                                else Hyprland.dispatch("hl.dsp.focus({ workspace = " + wsIndicator.workspaceId + " })")
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: root.content = workspaceComponent
}
