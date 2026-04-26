/* quickshell/widgets/base/notification/NotificationCard.qml */


import QtQuick
import QtQuick.Layouts


// Gradient border trick: outer rectangle filled with gradient,
// inner rectangle (the actual card) inset by border width.
Item {
    id: card

    property var entry: null

    implicitHeight: inner.implicitHeight + 2   // 1px border top + bottom
    implicitWidth:  inner.implicitWidth  + 2   // 1px border left + right

    // Fade in
    opacity: 0
    NumberAnimation on opacity {
        from: 0; to: 1
        duration: 150
        easing.type: Easing.OutCubic
        running: true
    }

    // ── Gradient border ────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius: 9

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#33ccff" }  // Cyan
            GradientStop { position: 1.0; color: "#00ff99" }  // Green
        }
    }

    // ── Card face ──────────────────────────────────────────────────────────
    Rectangle {
        id: inner
        anchors {
            fill:        parent
            margins:     1
        }
        radius:          8
        color:           "#1a3a5c"
        implicitHeight:  content.implicitHeight + 24

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
                    text:             entry?.appName || "Notification"
                    color:            "#93c5fd"
                    font.pixelSize:   11
                    Layout.fillWidth: true
                    elide:            Text.ElideRight
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
                visible:          text !== ""
                text:             entry?.summary ?? ""
                color:            "#eff6ff"
                font.pixelSize:   13
                font.bold:        true
                elide:            Text.ElideRight
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
