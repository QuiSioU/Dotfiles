/* quickshell/widgets/base/donut/DonutMenu.qml */


import Quickshell
import Quickshell.Wayland
import QtQuick
import ElysianShell.Themes

PanelWindow {
    id: donut_panwin
    color: "transparent"
    visible: false
    focusable: true

    property var entries: []
    
    property bool _pendingShow: false

    property real centerX: -1
    property real centerY: -1
    property bool centerSet: false
    
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

    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onVisibleChanged: {
        if (visible) {
            centerSet = false
            innerItem.forceActiveFocus()
        }
    }

    Connections {
        target: donut_panwin
        function onCenterSetChanged() { canvas.requestPaint() }
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
                if (!donut_panwin.centerSet) {
                    donut_panwin.centerX = mouse.x
                    donut_panwin.centerY = mouse.y
                    donut_panwin.centerSet = true
                }

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
        Canvas {
            id: canvas

            anchors.fill: parent
            property int hoveredIndex: donut_panwin.hoveredIndex
            property real centerX: donut_panwin.centerX
            property real centerY: donut_panwin.centerY

            onHoveredIndexChanged: requestPaint()
            onCenterXChanged: requestPaint()
            onCenterYChanged: requestPaint()
            Component.onCompleted: requestPaint()

            onPaint: {
                const ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                if (!donut_panwin.centerSet) return
                for (let i = 0; i < entries.length; i++) {
                    const sliceAngle = (2 * Math.PI) / entries.length
                    const startAngle = i * sliceAngle - Math.PI / 2
                    const endAngle   = startAngle + sliceAngle

                    ctx.beginPath()
                    ctx.arc(donut_panwin.centerX, donut_panwin.centerY, donut_panwin.innerRadius, startAngle, endAngle)
                    ctx.arc(donut_panwin.centerX, donut_panwin.centerY, donut_panwin.radius, endAngle, startAngle, true)
                    ctx.closePath()

                    ctx.fillStyle = i === hoveredIndex
                        ? "#0fffffff" : "#1616163d"
                    ctx.fill()
                    
                    ctx.lineWidth = 2
                
                    let grad = ctx.createLinearGradient(0, 0, width, height)
                    grad.addColorStop(0, ActiveTheme.colors["TERTIARY"])
                    grad.addColorStop(1, ActiveTheme.colors["ANSI_BLUE"])
                    
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
                    color: index === donut_panwin.hoveredIndex
                        ? ActiveTheme.colors["FG"] : ActiveTheme.colors["FG_DISABLED"]
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }
            }
        }
    }
}
