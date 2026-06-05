/* quickshell/widgets/base/orbit/OrbitMenu.qml */


import Quickshell
import Quickshell.Wayland
import QtQuick
import ElysianShell.Themes

PanelWindow {
    id: orbit_panwin
    color: "transparent"
    visible: false
    focusable: true

    property list<OrbitEntry> entries: []

    property bool _pendingShow: false
    property bool _pendingClose: false

    property real centerX:    0
    property real centerY:    0
    property real bubbleSize:  50
    property real orbitRadius: bubbleSize * 2
    property int  hoveredIndex: -1

    anchors {
        top: true;
        bottom: true;
        left: true;
        right: true
    }

    function closeMenu() {
        if (_pendingClose || !visible) return
        _pendingClose = true
        bubbleRepeater.triggerCollapse()
    }

    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onVisibleChanged: {
        if (visible) {
            centerX = -1
            centerY = -1
            _pendingShow = true
            innerItem.forceActiveFocus()
        }
    }

    Item {
        id: innerItem
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: orbit_panwin.closeMenu()

        Repeater {
            id: bubbleRepeater
            model: orbit_panwin.entries.length

            function triggerExpand() {
                for (let i = 0; i < count; i++) {
                    const item = itemAt(i)
                    if (item) item.expand()
                }
            }

            function triggerCollapse() {
                for (let i = 0; i < count; i++) {
                    const item = itemAt(i)
                    if (item) item.collapse()
                }
            }

            Item {
                id: bubbleItem

                readonly property var  entry:       orbit_panwin.entries[index]
                readonly property real sliceAngle:  (2 * Math.PI) / orbit_panwin.entries.length
                readonly property real targetAngle: index * sliceAngle - Math.PI / 2
                readonly property real targetX:     orbit_panwin.centerX + Math.cos(targetAngle) * orbit_panwin.orbitRadius
                readonly property real targetY:     orbit_panwin.centerY + Math.sin(targetAngle) * orbit_panwin.orbitRadius
                readonly property bool selected:    entry?.selected ?? false

                property bool hovered:      false
                property bool animating:    false

                width:  orbit_panwin.bubbleSize
                height: orbit_panwin.bubbleSize
                x: 0
                y: 0

                Behavior on x {
                    enabled: bubbleItem.animating
                    NumberAnimation {
                        duration: 450;
                        easing.type: orbit_panwin._pendingClose ? Easing.InBack : Easing.OutBack;
                        easing.overshoot: 1.5
                    }
                }
                Behavior on y {
                    enabled: bubbleItem.animating
                    NumberAnimation {
                        duration: 450;
                        easing.type: orbit_panwin._pendingClose ? Easing.InBack : Easing.OutBack;
                        easing.overshoot: 1.5
                    }
                }

                Timer {
                    id: hideTimer
                    interval: 450
                    repeat: false
                    running: index === 0 && orbit_panwin._pendingClose
                    onTriggered: {
                        orbit_panwin.visible = false
                        orbit_panwin._pendingClose = false
                    }
                }

                function expand() {
                    animating = false
                    x = orbit_panwin.centerX - orbit_panwin.bubbleSize / 2
                    y = orbit_panwin.centerY - orbit_panwin.bubbleSize / 2
                    animating = true
                    x = targetX - orbit_panwin.bubbleSize / 2
                    y = targetY - orbit_panwin.bubbleSize / 2
                }

                function collapse() {
                    animating = true
                    x = orbit_panwin.centerX - orbit_panwin.bubbleSize / 2
                    y = orbit_panwin.centerY - orbit_panwin.bubbleSize / 2
                }

                Rectangle {
                    anchors.fill: parent
                    radius: orbit_panwin.bubbleSize / 2

                    color: {
                        if (bubbleItem.hovered)   return ActiveTheme.colors["DARK4"]
                        if (bubbleItem.selected)  return ActiveTheme.colors["BG_HIGHLIGHT"]
                        return ActiveTheme.colors["BG"]
                    }

                    border.color: {
                        if (bubbleItem.selected)  return ActiveTheme.colors["ANSI_BLUE"]
                        if (bubbleItem.hovered)   return ActiveTheme.colors["FG_DARK"]
                        return ActiveTheme.colors["DARK3"]
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
                        color: bubbleItem.selected ? ActiveTheme.colors["FG"] : ActiveTheme.colors["DARK3"]
                        font.pixelSize: 16
                        font.weight: Font.Medium
                        visible: bubbleIcon.status !== Image.Ready
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        
                        onEntered:  { if (!orbit_panwin._pendingClose) bubbleItem.hovered = true }
                        onExited:   bubbleItem.hovered = false

                        onClicked: {
                            bubbleItem.entry.action()
                            if (!bubbleItem.entry.stateful) orbit_panwin.closeMenu()
                        }
                    }
                }

                // Tooltip
                Rectangle {
                    visible: bubbleItem.hovered && !orbit_panwin._pendingClose &&
                             ((bubbleItem.entry?.name ?? "") !== "" ||
                              (bubbleItem.entry?.comment ?? "") !== "")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.top
                    anchors.bottomMargin: 6
                    width:  tooltipCol.implicitWidth + 16
                    height: tooltipCol.implicitHeight + 10
                    color: ActiveTheme.colors["BG_HIGHLIGHT"]
                    border.color: bubbleItem.selected ? ActiveTheme.colors["ANSI_BLUE"] : ActiveTheme.colors["DARK3"]
                    border.width: 1
                    radius: 6
                    z: 10

                    Column {
                        id: tooltipCol
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            text: bubbleItem.entry?.name ?? ""
                            color: ActiveTheme.colors["FG"]
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            visible: text !== ""
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: bubbleItem.entry?.comment ?? ""
                            color: bubbleItem.selected
                                    ? ActiveTheme.colors["ACCENT_LOW"] : ActiveTheme.colors["FG_DISABLED"]
                            font.pixelSize: 11
                            visible: text !== ""
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }

        // This MouseArea covers the whole screen. Only used to capture mouse position (x, Y) on screen
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            z: -1

            onPositionChanged: mouse => {
                if (orbit_panwin._pendingShow) {
                    orbit_panwin.centerX = mouse.x
                    orbit_panwin.centerY = mouse.y
                    orbit_panwin._pendingShow = false
                    bubbleRepeater.triggerExpand()
                }
            }

            // Close menu if clicking outside of any bubble
            onClicked: { orbit_panwin.closeMenu() }
        }
    }
}
