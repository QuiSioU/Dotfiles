/* quickshell/widgets/LockScreen.qml */


import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ElysianShell.Themes


PanelWindow {
    id: root
    visible: false
    focusable: true
    color: "#cc000000"
    
    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "lock-screen"
    exclusionMode: ExclusionMode.Ignore

    signal unlocked()

    function lock()     { root.visible = true }
    function unlock()   { root.visible = false; root.unlocked() }

    Item {
        anchors.fill: parent
        focus: true

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                root.visible = false
                event.accepted = true
            }
        }
    }
}
