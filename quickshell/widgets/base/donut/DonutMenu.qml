/* widgets/base/donut/DonutMenu.qml */

import Quickshell
import Quickshell.Hyprland
import QtQuick
import ElyseanShell.Services

PanelWindow {
    id: donut_panwin
    color: "transparent"
    visible: false
    focusable: true

    property var entries: []

    property real centerX: CursorPosition.x
    property real centerY: CursorPosition.y - 50 // Eww topbar messing things up; will remove in the future
    
    property real innerRadius: 45
    property real radius: innerRadius * 2.4
    property int hoveredIndex: -1

    // Fill entire screen
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    HyprlandFocusGrab {
        windows: [ donut_panwin ]
        active: donut_panwin.visible
        onCleared: donut_panwin.visible = false
    }

    onVisibleChanged: {
        if (visible) innerItem.forceActiveFocus()
    }


    // Fullscreen mouse tracking area
    Item {
        id: innerItem
        anchors.fill: parent
        focus: true

        // Keyboard cancel
        Keys.onEscapePressed: donut_panwin.visible = false

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onPositionChanged: mouse => {
                const dx = mouse.x - donut_panwin.centerX
                const dy = mouse.y - donut_panwin.centerY
                const dist = Math.sqrt(dx * dx + dy * dy)

                if (dist < donut_panwin.innerRadius || entries.length === 0) {
                    donut_panwin.hoveredIndex = -1
                    return
                }

                // Get angle in degrees, 0 = up, clockwise
                let angle = Math.atan2(dy, dx) * 180 / Math.PI + 90
                if (angle < 0) angle += 360

                const sliceAngle = 360 / entries.length
                donut_panwin.hoveredIndex = Math.floor(angle / sliceAngle)
            }

            onClicked: mouse => {
                const dx = mouse.x - donut_panwin.centerX
                const dy = mouse.y - donut_panwin.centerY
                const dist = Math.sqrt(dx * dx + dy * dy)

                if (dist >= donut_panwin.innerRadius &&
                    dist <= donut_panwin.radius &&
                    donut_panwin.hoveredIndex >= 0 &&
                    donut_panwin.hoveredIndex < entries.length) {
                    entries[donut_panwin.hoveredIndex].action()
                }
                donut_panwin.visible = false
            }
        }

        // Donut slices
        Repeater {
            model: entries.length

            Canvas {
                anchors.fill: parent
                property int sliceIndex: index
                property bool hovered: sliceIndex === donut_panwin.hoveredIndex

                onHoveredChanged: requestPaint()

                Component.onCompleted: requestPaint()

                onPaint: {
                    const ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    const sliceAngle = (2 * Math.PI) / entries.length
                    const startAngle = sliceIndex * sliceAngle - Math.PI / 2
                    const endAngle   = startAngle + sliceAngle

                    if (width === 0 || height === 0) return

                    ctx.beginPath()
                    ctx.arc(donut_panwin.centerX, donut_panwin.centerY, donut_panwin.innerRadius, startAngle, endAngle)
                    ctx.arc(donut_panwin.centerX, donut_panwin.centerY, donut_panwin.radius, endAngle, startAngle, true)
                    ctx.closePath()

                    ctx.fillStyle = hovered ? "#45475a" : '#c826263e'
                    ctx.fill()
                    ctx.lineWidth = 2
                    
                    let grad = ctx.createLinearGradient(0, 0, width, height)
                    grad.addColorStop(0, "#33ccff") // Cyan
                    grad.addColorStop(1, "#00ff99") // Green
                    
                    ctx.strokeStyle = grad

                    ctx.stroke()
                }
            }
        }

        // Labels
        Repeater {
            model: entries.length

            Item {
                z: 2
                property real sliceAngle: (2 * Math.PI) / entries.length
                property real midAngle: index * sliceAngle - Math.PI / 2 + sliceAngle / 2
                property real labelRadius: (donut_panwin.radius + donut_panwin.innerRadius) / 2

                x: donut_panwin.centerX + Math.cos(midAngle) * labelRadius - 40
                y: donut_panwin.centerY + Math.sin(midAngle) * labelRadius - 12

                Text {
                    width: 80
                    horizontalAlignment: Text.AlignHCenter
                    text: entries[index].name
                    color: index === donut_panwin.hoveredIndex ? "#cdd6f4" : "#6c7086"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }
            }
        }
    }
}
