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

    default property list<QtObject> _children

    // Only OrbitEntry children reach the Repeater.
    readonly property var entries: _children.filter(c => c instanceof OrbitEntry)

    property bool _pendingShow: false

    property real centerX:    CursorPosition.x
    property real centerY:    CursorPosition.y - 50
    property real orbitRadius: 110
    property real bubbleSize:  52
    property int  hoveredIndex: -1

    implicitWidth:  Qt.application.screens[0].width
    implicitHeight: Qt.application.screens[0].height

    anchors {
        top: true;
        bottom: true;
        left: true;
        right: true
    }

    HyprlandFocusGrab {
        windows: [orbit_panwin]
        active: orbit_panwin.visible
        onCleared: orbit_panwin.visible = false
    }

    onVisibleChanged: {
        if (visible) {
            innerItem.forceActiveFocus()
            bubbleRepeater.triggerBang()
        }
    }

    Item {
        id: innerItem
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: orbit_panwin.visible = false

        Repeater {
            id: bubbleRepeater
            model: orbit_panwin.entries.length

            function triggerBang() {
                for (let i = 0; i < count; i++) {
                    const item = itemAt(i)
                    if (item) item.resetAndLaunch()
                }
            }

            Item {
                id: bubbleItem

                readonly property var  entry:       orbit_panwin.entries[index]
                readonly property real sliceAngle:  (2 * Math.PI) / orbit_panwin.entries.length
                readonly property real targetAngle: index * sliceAngle - Math.PI / 2
                readonly property real targetX:     orbit_panwin.centerX + Math.cos(targetAngle) * orbit_panwin.orbitRadius
                readonly property real targetY:     orbit_panwin.centerY + Math.sin(targetAngle) * orbit_panwin.orbitRadius
                readonly property bool hovered:     index === orbit_panwin.hoveredIndex
                readonly property bool selected:    entry?.selected ?? false

                property bool animating: false

                width:  orbit_panwin.bubbleSize
                height: orbit_panwin.bubbleSize
                x: orbit_panwin.centerX - orbit_panwin.bubbleSize / 2
                y: orbit_panwin.centerY - orbit_panwin.bubbleSize / 2

                Behavior on x {
                    enabled: bubbleItem.animating
                    NumberAnimation { duration: 450; easing.type: Easing.OutBack; easing.overshoot: 1.5 }
                }
                Behavior on y {
                    enabled: bubbleItem.animating
                    NumberAnimation { duration: 450; easing.type: Easing.OutBack; easing.overshoot: 1.5 }
                }

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

                function resetAndLaunch() {
                    animating = false
                    x = orbit_panwin.centerX - orbit_panwin.bubbleSize / 2
                    y = orbit_panwin.centerY - orbit_panwin.bubbleSize / 2
                    staggerTimer.restart()
                }

                Rectangle {
                    anchors.fill: parent
                    radius: orbit_panwin.bubbleSize / 2

                    color: {
                        if (bubbleItem.hovered)   return "#45475a"
                        if (bubbleItem.selected)  return "#313244"
                        return "#1e1e2e"
                    }

                    border.color: {
                        if (bubbleItem.selected)  return "#89b4fa"
                        if (bubbleItem.hovered)   return "#cdd6f4"
                        return "#6c7086"
                    }
                    border.width: bubbleItem.selected ? 1.5 : 0.5

                    Image {
                        id: bubbleIcon
                        anchors.centerIn: parent
                        width: 28; height: 28
                        source: bubbleItem.entry?.icon ?? ""
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        visible: status === Image.Ready
                        opacity: bubbleItem.selected ? 1.0 : 0.75
                    }

                    Text {
                        anchors.centerIn: parent
                        text: (bubbleItem.entry?.name ?? "").charAt(0).toUpperCase()
                        color: bubbleItem.selected ? "#cdd6f4" : "#6c7086"
                        font.pixelSize: 16
                        font.weight: Font.Medium
                        visible: bubbleIcon.status !== Image.Ready
                    }
                }

                // Tooltip
                Rectangle {
                    visible: bubbleItem.hovered &&
                             ((bubbleItem.entry?.name ?? "") !== "" ||
                              (bubbleItem.entry?.comment ?? "") !== "")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.top
                    anchors.bottomMargin: 6
                    width:  tooltipCol.implicitWidth + 16
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
                            text: bubbleItem.entry?.name ?? ""
                            color: "#cdd6f4"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            visible: text !== ""
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: bubbleItem.entry?.comment ?? ""
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

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true

            onPositionChanged: mouse => {
                let closest = -1
                let closestDist = orbit_panwin.bubbleSize / 2 + 8

                for (let i = 0; i < orbit_panwin.entries.length; i++) {
                    const angle = i * (2 * Math.PI / orbit_panwin.entries.length) - Math.PI / 2
                    const bx = orbit_panwin.centerX + Math.cos(angle) * orbit_panwin.orbitRadius
                    const by = orbit_panwin.centerY + Math.sin(angle) * orbit_panwin.orbitRadius
                    const dx = mouse.x - bx
                    const dy = mouse.y - by
                    const dist = Math.sqrt(dx*dx + dy*dy)
                    if (dist < closestDist) {
                        closestDist = dist
                        closest = i
                    }
                }
                orbit_panwin.hoveredIndex = closest
            }

            onClicked: {
                if (orbit_panwin.hoveredIndex >= 0 &&
                    orbit_panwin.hoveredIndex < orbit_panwin.entries.length) {
                    orbit_panwin.entries[orbit_panwin.hoveredIndex].action()
                }
                orbit_panwin.visible = false
            }
        }
    }
}
