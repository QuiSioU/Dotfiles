/* quickshell/widgets/base/orbit/OrbitMenu.qml */


import Quickshell
import Quickshell.Hyprland
import QtQuick
import ElyseanShell.Services

PanelWindow {
    id: orbit_panwin
    color: "transparent"
    visible: false
    focusable: true

    property var entries: []

    property bool _pendingShow: false

    property real centerX: CursorPosition.x
    property real centerY: CursorPosition.y - 50 // Eww topbar offset; remove when bar is built
    property real orbitRadius: 110
    property real bubbleSize: 52
    property int hoveredIndex: -1

    implicitWidth: Qt.application.screens[0].width
    implicitHeight: Qt.application.screens[0].height

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    HyprlandFocusGrab {
        windows: [ orbit_panwin ]
        active: orbit_panwin.visible
        onCleared: orbit_panwin.visible = false
    }

    onVisibleChanged: {
        if (visible) {
            innerItem.forceActiveFocus()
            // Trigger the big bang reset on every show
            bubbleRepeater.triggerBang()
        }
    }

    Item {
        id: innerItem
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: orbit_panwin.visible = false

        // Bubbles
        Repeater {
            id: bubbleRepeater
            model: entries.length

            // Called by onVisibleChanged every time the menu opens.
            // Resets every bubble to the cursor (no animation), then
            // re-arms each stagger timer so the bang fires again.
            function triggerBang() {
                for (let i = 0; i < count; i++) {
                    const item = itemAt(i)
                    if (item) item.resetAndLaunch()
                }
            }

            Item {
                id: bubbleItem
                property real sliceAngle: (2 * Math.PI) / entries.length
                property real targetAngle: index * sliceAngle - Math.PI / 2
                property real targetX: orbit_panwin.centerX + Math.cos(targetAngle) * orbit_panwin.orbitRadius
                property real targetY: orbit_panwin.centerY + Math.sin(targetAngle) * orbit_panwin.orbitRadius
                property bool hovered: index === orbit_panwin.hoveredIndex

                // Controls whether Behaviors are active.
                // Must be false during the instant cursor-snap so QML
                // doesn't animate the "reset" move.
                property bool animating: false

                width: orbit_panwin.bubbleSize
                height: orbit_panwin.bubbleSize

                x: orbit_panwin.centerX - orbit_panwin.bubbleSize / 2
                y: orbit_panwin.centerY - orbit_panwin.bubbleSize / 2

                Behavior on x {
                    enabled: bubbleItem.animating
                    NumberAnimation {
                        duration: 450
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.5
                    }
                }
                Behavior on y {
                    enabled: bubbleItem.animating
                    NumberAnimation {
                        duration: 450
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.5
                    }
                }

                // Stagger timer — restarted on every bang via resetAndLaunch()
                Timer {
                    id: staggerTimer
                    interval: index * 30
                    repeat: false
                    running: false
                    onTriggered: {
                        bubbleItem.animating = true
                        bubbleItem.x = bubbleItem.targetX - orbit_panwin.bubbleSize / 2
                        bubbleItem.y = bubbleItem.targetY - orbit_panwin.bubbleSize / 2
                    }
                }

                // Called by Repeater.triggerBang() each time the menu opens
                function resetAndLaunch() {
                    // 1. Kill any in-flight animation and snap back to cursor instantly
                    animating = false
                    x = orbit_panwin.centerX - orbit_panwin.bubbleSize / 2
                    y = orbit_panwin.centerY - orbit_panwin.bubbleSize / 2

                    // 2. Re-arm the stagger timer so the bang fires again
                    staggerTimer.restart()
                }

                // Bubble circle
                Rectangle {
                    anchors.fill: parent
                    radius: orbit_panwin.bubbleSize / 2
                    color: bubbleItem.hovered ? "#45475a" : "#1e1e2e"
                    border.color: bubbleItem.hovered ? "#cdd6f4" : "#6c7086"
                    border.width: bubbleItem.hovered ? 1.5 : 0.5

                    // App icon
                    Image {
                        id: bubbleIcon
                        anchors.centerIn: parent
                        width: 28
                        height: 28
                        source: entries[index].icon ? "image://icon/" + entries[index].icon : ""
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        visible: status === Image.Ready
                    }

                    // Fallback letter
                    Text {
                        anchors.centerIn: parent
                        text: (entries[index].name ?? "").charAt(0).toUpperCase()
                        color: "#cdd6f4"
                        font.pixelSize: 16
                        font.weight: Font.Medium
                        visible: bubbleIcon.status !== Image.Ready
                    }
                }

                // Tooltip on hover
                Rectangle {
                    visible: bubbleItem.hovered && (entries[index].name !== "" || entries[index].comment !== "")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.top
                    anchors.bottomMargin: 6
                    width: tooltipCol.implicitWidth + 16
                    height: tooltipCol.implicitHeight + 10
                    color: "#1e1e2e"
                    border.color: "#45475a"
                    border.width: 0.5
                    radius: 6
                    z: 10

                    Column {
                        id: tooltipCol
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            text: entries[index].name ?? ""
                            color: "#cdd6f4"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            visible: text !== ""
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: entries[index].comment ?? ""
                            color: "#6c7086"
                            font.pixelSize: 11
                            visible: text !== ""
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }

        // Invisible mouse tracking overlay (on top of bubbles for hover detection)
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true

            onPositionChanged: mouse => {
                let closest = -1
                let closestDist = orbit_panwin.bubbleSize / 2 + 8 // hit radius

                for (let i = 0; i < entries.length; i++) {
                    const sliceAngle = (2 * Math.PI) / entries.length
                    const angle = i * sliceAngle - Math.PI / 2
                    const bx = orbit_panwin.centerX + Math.cos(angle) * orbit_panwin.orbitRadius
                    const by = orbit_panwin.centerY + Math.sin(angle) * orbit_panwin.orbitRadius
                    const dx = mouse.x - bx
                    const dy = mouse.y - by
                    const dist = Math.sqrt(dx * dx + dy * dy)
                    if (dist < closestDist) {
                        closestDist = dist
                        closest = i
                    }
                }
                orbit_panwin.hoveredIndex = closest
            }

            onClicked: mouse => {
                if (orbit_panwin.hoveredIndex >= 0 &&
                    orbit_panwin.hoveredIndex < entries.length) {
                    entries[orbit_panwin.hoveredIndex].action()
                }
                orbit_panwin.visible = false
            }
        }
    }
}
