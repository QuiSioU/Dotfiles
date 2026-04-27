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

    // Progress bar animation for each of the cards, even if they como from the same app/program
    onEntryChanged: { if (entry !== null) startTimer.restart() }

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
        implicitHeight:  content.childrenRect.height + 24

        ColumnLayout {
            id: content
            anchors {
                top:          parent.top
                left:         parent.left
                right:        parent.right
                leftMargin:   12
                rightMargin:  12
                topMargin:    12
                bottomMargin: 12
            }
            spacing: 4

            // App icon + App name
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Image {
                    source:   entry?.icon ?? ""
                    Layout.preferredWidth:    48
                    Layout.preferredHeight:   48
                    fillMode: Image.PreserveAspectFit
                    smooth:   true
                    visible:  status !== Image.Error && source !== ""
                }

                Text {
                    text:             entry?.appName || "Notification"
                    color:            "#93c5fd"
                    font.pixelSize:   20
                    font.family: "FiraCode Nerd Font Mono"
                    Layout.fillWidth: true
                    elide:            Text.ElideRight
                }
            }

            // Summary
            Text {
                visible:          text !== ""
                text:             entry?.summary ?? ""
                color:            "#eff6ff"
                font.pixelSize:   13
                font.bold:        true
                font.family: "FiraCode Nerd Font Mono"
                font.hintingPreference: Font.PreferNoHinting
                renderType: Text.QtRendering
                elide:            Text.ElideRight
                Layout.fillWidth: true
            }

            // Body
            Text {
                visible:          text !== ""
                text:             entry?.body ?? ""
                color:            "#bfdbfe"
                font.pixelSize:   12
                font.family: "FiraCode Nerd Font Mono"
                wrapMode:         Text.Wrap
                maximumLineCount: 3
                elide:            Text.ElideRight
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                Layout.topMargin: 4

                // ── Reverse progress bar ───────────────────────────────────────────
                Item {
                    id: progressBar
                    Layout.fillWidth: true
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
                            id: startTimer
                            interval: 50
                            running:  true
                            repeat:   false
                            onTriggered: {
                                progressFill.width = progressBar.width
                                widthAnim.stop()
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

                // Dismiss button
                Text {
                    text:  "󱞵 Dismiss"
                    color: closeArea.containsMouse ? "#60a5fa" : "#ffffff"
                    font.pixelSize: 11
                    font.family:    "FiraCode Nerd Font Mono"

                    MouseArea {
                        id:           closeArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    entry?.dismiss()
                    }
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
