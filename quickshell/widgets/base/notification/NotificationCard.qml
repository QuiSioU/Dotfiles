/* quickshell/widgets/base/notification/NotificationCard.qml */


import QtQuick
import QtQuick.Layouts

Rectangle {
    id: card

    property var entry: null

    implicitHeight: content.implicitHeight + 24
    radius:         8
    color:          "#1a3a5c"
    border.color:   "#3b82f6"
    border.width:   1

    // Fade in
    opacity: 0
    NumberAnimation on opacity {
        from: 0; to: 1
        duration: 150
        easing.type: Easing.OutCubic
        running: true
    }

    ColumnLayout {
        id: content
        anchors {
            fill:         parent
            leftMargin:   14
            rightMargin:  14
            topMargin:    12
            bottomMargin: 12
        }
        spacing: 4

        // App name + dismiss button
        RowLayout {
            Layout.fillWidth: true

            Text {
                text:           entry?.appName || "Notification"
                color:          "#93c5fd"
                font.pixelSize: 11
                Layout.fillWidth: true
                elide:          Text.ElideRight
            }

            Text {
                text:  "✕"
                color: closeArea.containsMouse ? "#f87171" : "#60a5fa"
                font.pixelSize: 11

                MouseArea {
                    id:           closeArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    entry?.dismiss()
                }
            }
        }

        // Summary
        Text {
            visible:        text !== ""
            text:           entry?.summary ?? ""
            color:          "#eff6ff"
            font.pixelSize: 13
            font.bold:      true
            elide:          Text.ElideRight
            Layout.fillWidth: true
        }

        // Body
        Text {
            visible:          text !== ""
            text:             entry?.body ?? ""
            color:            "#bfdbfe"
            font.pixelSize:   12
            wrapMode:         Text.Wrap
            maximumLineCount: 3
            elide:            Text.ElideRight
            Layout.fillWidth: true
        }

        // Progress bar
        Item {
            Layout.fillWidth: true
            Layout.topMargin: 2
            height: 2

            Rectangle {
                anchors.fill: parent
                radius: 1
                color:  "#1e3a5f"
            }

            Rectangle {
                id:     bar
                height: parent.height
                width:  parent.width
                radius: 1
                color:  "#3b82f6"

                NumberAnimation on width {
                    from:        bar.parent.width
                    to:          0
                    duration:    4000
                    running:     true
                    easing.type: Easing.Linear
                }
            }
        }
    }

    // Click card body to dismiss
    MouseArea {
        anchors.fill:      parent
        anchors.topMargin: 26
        z:                 -1
        cursorShape:       Qt.PointingHandCursor
        onClicked:         entry?.dismiss()
    }
}
