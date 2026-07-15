import QtQuick
import Quickshell.Hyprland
import ElysianShell.Themes
import "base"

MorphingPill {
    id: root
    color: ActiveTheme.colors["BG"]

    Row {
        id: dots
        spacing: 6
        anchors.centerIn: parent

        Repeater {
            model: 5

            Rectangle {
                id: dot
                required property int index

                readonly property int workspaceId: index + 1
                readonly property bool active: Hyprland.focusedWorkspace?.id === workspaceId

                width: 10
                height: 10
                radius: width / 2
                color: active ? ActiveTheme.colors["ANSI_BLUE"] : ActiveTheme.colors["ANSI_RED"]

                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }

    Component.onCompleted: root.content = dots
}
