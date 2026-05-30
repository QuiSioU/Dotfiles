/* quickshell/widgets/base/notification/NotificationCard.qml */

import QtQuick
import QtQuick.Layouts
import ElyseanShell.Themes

// Lifecycle:
//   1. fade in + slide circle left  → reveals panel
//   2. radial countdown (timeoutMs)
//   3. slide circle right           → hides panel
//   4. fade out circle

Item {
    id: card

    property var entry: null
    property int timeoutMs: 4000

    readonly property int d:           60
    readonly property int bw:          2
    readonly property int panelWidth:  260
    readonly property int panelHeight: Math.round(d * 3 / 4)

    implicitWidth:  panelWidth
    implicitHeight: d

    onEntryChanged: { if (entry !== null) introTimer.restart() }

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
    Item {
        id: panelClip
        clip: true
        anchors.verticalCenter: parent.verticalCenter
        x:      circle.x + card.d / 2
        width:  card.panelWidth - circle.x - card.d / 2
        height: card.panelHeight

        Item {
            x:      -(circle.x + card.d / 2)
            width:  card.panelWidth
            height: card.panelHeight

            Rectangle {
                anchors.fill: parent
                radius:       card.panelHeight / 2
                color:        card.accentColor
            }

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
                }
            }
        }
    }

    // ── Circle ────────────────────────────────────────────────────────────
    Item {
        id: circle
        width:  card.d
        height: card.d
        x:      card.panelWidth - card.d
        anchors.verticalCenter: parent.verticalCenter
        z: 1

        // Track ring (background)
        Rectangle {
            anchors.fill: parent
            radius:       width / 2
            color:        ActiveTheme.colors["BG_HIGHLIGHT"]
        }

        // Inner face
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

        // Radial progress arc
        Canvas {
            id: progressArc
            anchors.fill: parent

            // 1.0 = full ring → 0.0 = empty
            property real progress: 1.0
            onProgressChanged: requestPaint()

            property color arcColor: card.accentColor
            onArcColorChanged: requestPaint()

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                var cx  = width  / 2
                var cy  = height / 2
                var r   = (Math.min(width, height) - card.bw) / 2
                var startAngle = -Math.PI / 2
                var endAngle   = startAngle + progress * 2 * Math.PI
                ctx.beginPath()
                ctx.arc(cx, cy, r, startAngle, endAngle, false)
                ctx.strokeStyle = arcColor
                ctx.lineWidth   = card.bw
                ctx.lineCap     = "round"
                ctx.stroke()
            }
        }
    }

    // ── Sequence ───────────────────────────────────────────────────────────

    opacity: 0

    Timer {
        id: introTimer
        interval: 80
        repeat:   false
        running:  false
        onTriggered: {
            circle.x             = card.panelWidth - card.d
            progressArc.progress = 1.0
            lifecycleAnim.restart()
        }
    }

    SequentialAnimation {
        id: lifecycleAnim
        running: false

        // 1. Fade in
        NumberAnimation {
            target:      card
            property:    "opacity"
            from:        0.0
            to:          1.0
            duration:    150
            easing.type: Easing.OutCubic
        }

        // 2. Slide circle left → reveal panel
        NumberAnimation {
            target:      circle
            property:    "x"
            from:        card.panelWidth - card.d
            to:          0
            duration:    400
            easing.type: Easing.OutCubic
        }

        // 3. Radial countdown
        NumberAnimation {
            target:      progressArc
            property:    "progress"
            from:        1.0
            to:          0.0
            duration:    card.timeoutMs
            easing.type: Easing.Linear
        }

        // 4. Slide circle right → hide panel
        NumberAnimation {
            target:      circle
            property:    "x"
            to:          card.panelWidth - card.d
            duration:    400
            easing.type: Easing.InCubic
        }

        // 5. Fade out
        NumberAnimation {
            target:      card
            property:    "opacity"
            from:        1.0
            to:          0.0
            duration:    200
            easing.type: Easing.InCubic
        }

        onStopped: { if (!lifecycleAnim.running) entry?.dismiss() }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape:  Qt.PointingHandCursor
        onClicked:    entry?.dismiss()
    }
}
