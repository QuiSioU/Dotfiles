/* quickshell/widgets/base/notification/NotificationCard.qml */

import QtQuick
import QtQuick.Layouts
import ElyseanShell.Themes

// Animation: circle slides from right to left, revealing the panel behind it.
// Final state: circle at x=0, overlapping the left cap of the panel.

Item {
    id: card

    property var entry: null
    property int timeoutMs: 4000

    readonly property int d:           60
    readonly property int bw:          2
    readonly property int panelWidth:  260
    readonly property int panelHeight: Math.round(d * 2 / 3)

    // Total width: panel spans 0..panelWidth, right half of circle sticks out = panelWidth
    implicitWidth:  panelWidth
    implicitHeight: d

    onEntryChanged: { if (entry !== null) slideTimer.restart() }

    // ── Accent colour ──────────────────────────────────────────────────────
    property color accentColor: {
        const cat = entry?.category ?? ""
        if (cat.includes("error"))    return ActiveTheme.colors["ERROR_LOW"]
        if (cat.includes("complete")) return ActiveTheme.colors["SUCCESS_MUTED"]
        if (cat.includes("warning"))  return ActiveTheme.colors["WARNING_LOW"]
        switch (entry?.urgency ?? 1) {
            case 0:  return ActiveTheme.colors["FG_DISABLED"]
            case 2:  return ActiveTheme.colors["URGENT"]
            default: return ActiveTheme.colors["ANSI_BLUE"]
        }
    }

    // ── Panel clip ─────────────────────────────────────────────────────────
    // Left edge glued to circle's right edge, right edge fixed at panelWidth.
    // Width = panelWidth - (circle.x + d): 0 at start, (panelWidth-d) at rest.
    Item {
        id: panelClip
        clip: true
        anchors.verticalCenter: parent.verticalCenter
        x:      circle.x + card.d / 2
        width:  card.panelWidth - circle.x - card.d / 2
        height: card.panelHeight

        // Content offset so it appears at its final absolute position (x=0 in card space)
        // Absolute x of inner item = clip.x + inner.x = (circle.x+d) + (-(circle.x+d)) = 0
        Item {
            x:      -(circle.x + card.d / 2)
            width:  card.panelWidth
            height: card.panelHeight

            // Gradient border
            Rectangle {
                anchors.fill: parent
                radius:       card.panelHeight / 2
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: card.accentColor }
                    GradientStop { position: 1.0; color: ActiveTheme.colors["FG_DARK"] }
                }
            }

            // Inner face
            Rectangle {
                anchors { fill: parent; margins: card.bw }
                radius: (card.panelHeight - card.bw * 2) / 2
                color:  ActiveTheme.colors["ANSI_BLACK"]

                ColumnLayout {
                    anchors {
                        left:         parent.left
                        right:        parent.right
                        top:          parent.top
                        bottom:       parent.bottom
                        leftMargin:   card.d + 8
                        rightMargin:  12
                        topMargin:    6
                        bottomMargin: 6
                    }
                    spacing: 2

                    Text {
                        text:             entry?.appName || "Notification"
                        color:            card.accentColor
                        font.pixelSize:   13
                        font.bold:        true
                        font.family:      "JetBrainsMono Nerd Font"
                        Layout.fillWidth: true
                        elide:            Text.ElideRight
                    }

                    Text {
                        visible:          text !== ""
                        text:             entry?.summary ?? ""
                        color:            ActiveTheme.colors["FG"]
                        font.pixelSize:   11
                        font.family:      "JetBrainsMono Nerd Font"
                        font.hintingPreference: Font.PreferNoHinting
                        renderType:       Text.QtRendering
                        elide:            Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        visible:          text !== ""
                        text:             entry?.body ?? ""
                        color:            ActiveTheme.colors["FG_DARK"]
                        font.pixelSize:   10
                        font.family:      "JetBrainsMono Nerd Font"
                        wrapMode:         Text.Wrap
                        maximumLineCount: 2
                        elide:            Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Item {
                        id: progressBar
                        Layout.fillWidth: true
                        height: 3

                        Rectangle {
                            anchors.fill: parent
                            radius: 2
                            color:  ActiveTheme.colors["BG_HIGHLIGHT"]
                        }

                        Rectangle {
                            id: progressFill
                            anchors { top: parent.top; left: parent.left; bottom: parent.bottom }
                            radius: 2
                            width:  0
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: card.accentColor }
                                GradientStop { position: 1.0; color: ActiveTheme.colors["FG_DARK"] }
                            }

                            Timer {
                                id: startTimer
                                interval: 0
                                repeat:   false
                                running:  false
                                onTriggered: {
                                    progressFill.width = progressBar.width
                                    widthAnim.stop()
                                    widthAnim.from = progressBar.width
                                    widthAnim.to   = 0
                                    widthAnim.start()
                                }
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
        }
    }

    // ── Circle ────────────────────────────────────────────────────────────
    Item {
        id: circle
        width:  card.d
        height: card.d
        x:      card.panelWidth - card.d   // starts at right edge, fully visible
        anchors.verticalCenter: parent.verticalCenter
        z: 1

        Rectangle {
            anchors.fill: parent
            radius:       width / 2
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: card.accentColor }
                GradientStop { position: 1.0; color: ActiveTheme.colors["FG_DARK"] }
            }
        }

        Rectangle {
            anchors { fill: parent; margins: card.bw }
            radius: width / 2
            color:  ActiveTheme.colors["ANSI_BLACK"]

            Image {
                anchors.centerIn: parent
                width:  parent.width  - 12
                height: parent.height - 12
                source:   entry?.icon ?? ""
                fillMode: Image.PreserveAspectFit
                smooth:   true
                visible:  status !== Image.Error && source !== ""
            }

            Text {
                anchors.centerIn: parent
                text:    entry?.appName?.charAt(0)?.toUpperCase() ?? "?"
                color:   card.accentColor
                font.pixelSize: 20
                font.family:    "JetBrainsMono Nerd Font"
                visible: (entry?.icon ?? "") === ""
            }
        }
    }

    // ── Slide animation ────────────────────────────────────────────────────
    Timer {
        id: slideTimer
        interval: 80
        repeat:   false
        running:  false
        onTriggered: {
            circle.x = card.panelWidth - card.d
            slideAnim.start()
        }
    }

    NumberAnimation {
        id:          slideAnim
        target:      circle
        property:    "x"
        from:        card.panelWidth - card.d
        to:          0
        duration:    400
        easing.type: Easing.OutCubic
        running:     false
        onStopped:   { if (circle.x <= 0) startTimer.restart() }
    }

    opacity: 0
    NumberAnimation on opacity {
        from: 0; to: 1
        duration: 150
        easing.type: Easing.OutCubic
        running: true
    }

    MouseArea {
        anchors.fill: parent
        cursorShape:  Qt.PointingHandCursor
        onClicked:    entry?.dismiss()
    }
}
