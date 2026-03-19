import Quickshell
import Quickshell.Hyprland
import QtQuick


PanelWindow {
    id: win
    implicitWidth: 600
    implicitHeight: 60
    focusable: true

    HyprlandFocusGrab {
        windows: [ win ]
        active: true
        onCleared: win.visible = false
    }

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"
        radius: 12
        

        TextInput {
            id: searchInput
            anchors.fill: parent
            anchors.margins: 16
            focus: true
            color: "#cdd6f4"
            font.pixelSize: 22
            selectionColor: "#89b4fa"

            // Special keys — handled BEFORE TextInput consumes them
            Keys.priority: Keys.BeforeItem
            Keys.onReturnPressed: console.log(text)
            Keys.onTabPressed: win.visible = false
            Keys.onEscapePressed: Qt.quit()
        }
    }
}
