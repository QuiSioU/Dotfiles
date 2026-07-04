/* quickshell/widgets/base/LockVisual.qml */


import QtQuick
import QtQuick.Effects

Item {
    id: root
    property string wallpaper: ""

    Image {
        id: bg
        anchors.fill: parent
        source: root.wallpaper
        fillMode: Image.PreserveAspectCrop
        opacity: 0   // never shown directly — only feeds MultiEffect below
        cache: true
        asynchronous: true
    }

    MultiEffect {
        anchors.fill: parent
        source: bg
        blurEnabled: true
        blur: 1.0
        blurMultiplier: 2.5
        brightness: -0.15
    }

    Text {
        anchors.centerIn: parent
        color: "white"
        font.pixelSize: 64
        font.bold: true
        text: Qt.formatTime(new Date(), "hh:mm")

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: parent.text = Qt.formatTime(new Date(), "hh:mm")
        }
    }
}
