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

    anchors {
        top: true;
        bottom: true;
        left: true;
        right: true
    }

    function closeMenu() {
        if (!visible) return
        bubbleRepeater.triggerCollapse()
    }

    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onVisibleChanged: { if (visible) root.open() }

    Item {
        id: root
        anchors.fill: parent
        focus: true

        property bool fetchMousePos:        false
        property real centerX:              0
        property real centerY:              0
        property real bubbleSize:           50
        property real orbitRadius:          bubbleSize * 2
        property list<OrbitEntry> entries:  orbit_panwin.entries

        Keys.onEscapePressed: orbit_panwin.closeMenu()

        function open() {
            centerX = -1
            centerY = -1
            fetchMousePos = true
            forceActiveFocus()
        }

        Repeater {
            id: bubbleRepeater
            model: root.entries.length

            function triggerExpand() {
                for (let i = 0; i < count; i++) {
                    const item = itemAt(i)
                    if (item) item.expandBubble()
                }
            }

            function triggerCollapse() {
                for (let i = 0; i < count; i++) {
                    const item = itemAt(i)
                    if (item) item.collapseBubble()
                }
            }

            Item {
                id: bubbleItem

                readonly property var  entry:       root.entries[index]
                readonly property real sliceAngle:  (2 * Math.PI) / root.entries.length
                readonly property real targetAngle: index * sliceAngle - Math.PI / 2
                readonly property real targetX:     root.centerX + Math.cos(targetAngle) * root.orbitRadius
                readonly property real targetY:     root.centerY + Math.sin(targetAngle) * root.orbitRadius
                readonly property bool selected:    entry?.selected ?? false

                property bool hovered:      false

                width:  root.bubbleSize
                height: root.bubbleSize
                x: 0
                y: 0
                opacity: root.fetchMousePos ? 0 : 1

                function expandBubble() {
                    if (collapseAnimation.running) return
                    expandAnimation.start()
                }

                function collapseBubble() {
                    if (expandAnimation.running) return
                    collapseAnimation.start()
                }

                SequentialAnimation {
                    id: expandAnimation
                    running: false

                    ParallelAnimation {
                        NumberAnimation {
                            target:             bubbleItem
                            property:           "x"
                            from:               root.centerX - root.bubbleSize / 2
                            to:                 targetX - root.bubbleSize / 2
                            duration:           450
                            easing.type:        Easing.OutBack
                            easing.overshoot:   1.5
                        }
                        NumberAnimation {
                            target:             bubbleItem
                            property:           "y"
                            from:               root.centerY - root.bubbleSize / 2
                            to:                 targetY - root.bubbleSize / 2
                            duration:           450
                            easing.type:        Easing.OutBack
                            easing.overshoot:   1.5
                        }
                    }
                }

                SequentialAnimation {
                    id: collapseAnimation
                    running: false

                    ParallelAnimation {
                        NumberAnimation {
                            target:             bubbleItem
                            property:           "x"
                            to:                 root.centerX - root.bubbleSize / 2
                            duration:           450
                            easing.type:        Easing.InBack
                            easing.overshoot:   1.5
                        }
                        NumberAnimation {
                            target:             bubbleItem
                            property:           "y"
                            to:                 root.centerY - root.bubbleSize / 2
                            duration:           450
                            easing.type:        Easing.InBack
                            easing.overshoot:   1.5
                        }
                    }

                    onStopped: {
                        if (index === root.entries.length - 1) {
                            orbit_panwin.visible = false
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: root.bubbleSize / 2

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
                        
                        onEntered: {
                            if (!expandAnimation.running && !collapseAnimation.running) {
                                bubbleItem.hovered = true
                            }
                        }
                        onExited: bubbleItem.hovered = false

                        onClicked: {
                            bubbleItem.entry.action()
                            if (!bubbleItem.entry.stateful) orbit_panwin.closeMenu()
                        }
                    }
                }

                // Tooltip
                Rectangle {
                    visible: bubbleItem.hovered && !expandAnimation.running && !collapseAnimation.running &&
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
                if (root.fetchMousePos) {
                    root.centerX = mouse.x
                    root.centerY = mouse.y
                    root.fetchMousePos = false
                    bubbleRepeater.triggerExpand()
                }
            }

            // Close menu if clicking outside of any bubble
            onClicked: { orbit_panwin.closeMenu() }
        }
    }
}
