/* quickshell/widgets/base/notification/NotificationCard.qml */


import QtQuick
import QtQuick.Layouts
import ElyseanShell.Themes


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

    property color accentColor: {
        const cat = entry?.category ?? ""
        if (cat.includes("error"))    return ActiveTheme.color["ERROR_MUTED"]
        if (cat.includes("complete")) return ActiveTheme.color["SUCCESS_MUTED"]
        if (cat.includes("warning"))  return ActiveTheme.color["WARNING_MUTED"]
        switch (entry?.urgency ?? 1) {
            case 0:  return ActiveTheme.color["FG_DISABLED"]
            case 2:  return ActiveTheme.color["URGENT"]
            default: return ActiveTheme.color["ACCENT"]
        }
    }

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
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: card.accentColor }
            GradientStop { position: 1.0; color: ActiveTheme.color["FG_DARK"] }
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
        color:           ActiveTheme.color["TERMINAL_BLACK"]
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
                    color:            card.accentColor
                    font.pixelSize:   20
                    font.family: "JetBrainsMono Nerd Font"
                    Layout.fillWidth: true
                    elide:            Text.ElideRight
                }
            }

            // Summary
            Text {
                visible:          text !== ""
                text:             entry?.summary ?? ""
                color:            ActiveTheme.color["FG"]
                font.pixelSize:   13
                font.bold:        true
                font.family: "JetBrainsMono Nerd Font"
                font.hintingPreference: Font.PreferNoHinting
                renderType: Text.QtRendering
                elide:            Text.ElideRight
                Layout.fillWidth: true
            }

            // Body
            Text {
                visible:          text !== ""
                text:             entry?.body ?? ""
                color:            ActiveTheme.color["FG_DARK"]
                font.pixelSize:   12
                font.family: "JetBrainsMono Nerd Font"
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
                    height: 5

                    // Track (background)
                    Rectangle {
                        anchors.fill: parent
                        radius:       2
                        color:        ActiveTheme.color["SURFACE"]
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
                            GradientStop { position: 0.0; color: card.accentColor }
                            GradientStop { position: 1.0; color: ActiveTheme.color["FG_DARK"] }
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
                    color: closeArea.containsMouse ? ActiveTheme.color["ACCENT"] : ActiveTheme.color["FG_DARK"]
                    font.pixelSize: 11
                    font.family:    "JetBrainsMono Nerd Font"

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
