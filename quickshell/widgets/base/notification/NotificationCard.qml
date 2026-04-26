/* quickshell/widgets/base/notification/NotificationCard.qml */


import QtQuick
import QtQuick.Layouts


// Gradient border trick: outer rectangle filled with gradient,
// inner rectangle (the actual card) inset by border width.
Item {
    id: card

    property var entry: null
    property int timeoutMs: 4000   // total lifetime in milliseconds

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
        implicitHeight:  content.implicitHeight + 24 + progressBar.height + 16

        ColumnLayout {
            id: content
            anchors {
                top:          parent.top
                left:         parent.left
                right:        parent.right
                leftMargin:   14
                rightMargin:  14
                topMargin:    12
                bottomMargin: 0
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

        // ── Reverse progress bar ───────────────────────────────────────────
        Item {
            id: progressBar
            anchors {
                left:         parent.left
                right:        parent.right
                bottom:       parent.bottom
                leftMargin:   8
                rightMargin:  8
                bottomMargin: 8
            }
            height: 10

            // Track (background)
            Rectangle {
                anchors.fill: parent
                radius:       2
                color:        "#0d2a45"
            }

            // Fill — anchored to the RIGHT so it shrinks leftward
            Rectangle {
                id: progressFill
                anchors {
                    top:    parent.top
                    left:  parent.left
                    bottom: parent.bottom
                }
                radius: 2
                width:  0   // NO binding — animation must own this property

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#33ccff" }
                    GradientStop { position: 1.0; color: "#00ff99" }
                }

                // interval:0 fires after the current event loop tick,
                // by which point anchors/widths are fully resolved
                Timer {
                    interval: 0
                    running:  true
                    repeat:   false
                    onTriggered: {
                        progressFill.width = progressBar.width
                        widthAnim.from     = progressBar.width
                        widthAnim.to       = 0
                        widthAnim.start()
                    }
                }

                NumberAnimation {
                    id:          widthAnim
                    target:      progressFill
                    property:    "width"
                    duration:    card.timeoutMs
                    running:     false
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
