import QtQuick 6.0
import Quickshell
import Quickshell.Wayland

PanelWindow {
    anchors {
        top: true
        right: true
        left: true
    }

    implicitHeight: 30

    Text {
        anchors.centerIn: parent
        text: "tonto el q lo lea"
    }
}