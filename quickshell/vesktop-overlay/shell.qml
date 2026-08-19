/* quickshell/shell/vesktop-overlay/shell.qml */


import QtQuick
import Quickshell

ShellRoot {
    id: root

    Loader { source: "widgets/ThemeLoader.qml" }

    Loader { source: "widgets/CallOSD.qml"; anchors.fill: parent }
}
