/* quickshell/shell/vesktop-overlay/shell.qml */


import QtQuick
import Quickshell

ShellRoot {
    id: root

    Loader {
        anchors.fill: parent
        source: "widgets/CallOSD.qml"
    }
}
