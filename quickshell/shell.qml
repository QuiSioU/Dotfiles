import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts


PanelWindow {
    id: panwin
    implicitWidth: 750
    implicitHeight: 500
    color: "transparent"
    focusable: true

    HyprlandFocusGrab {
        windows: [ panwin ]
        active: true
        onCleared: panwin.visible = false
    }

    // Main Geometry root
    Rectangle {
        id: root
        anchors.fill: parent
        color: "#1e1e2e"
        radius: 12
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20  // "padding" between borders
            spacing: 20  // "padding" between children

            // Top rectangle: text entry
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: "#181825"
                radius: 12
                

                TextInput {
                    id: searchInput
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter  // Center text vertically inside text input
                    anchors.margins: 16
                    focus: true
                    color: "#cdd6f4"
                    font.pixelSize: 16
                    
                    Keys.priority: Keys.BeforeItem
                    Keys.onReturnPressed: console.log(text)
                    Keys.onEscapePressed: Qt.quit()
                }
            }

            // Search results
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#181825"
                
                // Content goes here
            }
        }
    }
}
