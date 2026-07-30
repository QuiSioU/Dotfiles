/* quickshell/shell/widgets/base/SlideBar.qml */


import QtQuick
import ElysianShell.Themes

Item {
    id: root
    property real value: 0.5
    property bool pressed: mouseArea.pressed
    property bool growHorizontal: true

    readonly property int _animDuration: 100
    readonly property var _easingType: Easing.Linear

    signal setValue(real newValue)

    width: 200
    height: 6

    // background track
    Rectangle {
        id: track
        anchors.fill: parent
        radius: width > height ? height / 2 : width / 2
        color: ActiveTheme.colors["DARK7"]
    }

    // progressive fill
    Rectangle {
        id: fill

        anchors.left: parent.left
        anchors.right: root.growHorizontal ? undefined : parent.right
        anchors.top:   root.growHorizontal ? parent.top : undefined
        anchors.bottom: parent.bottom

        radius: width > height ? height / 2 : width / 2
        width:  root.growHorizontal ? track.width * root.value : parent.width
        height: root.growHorizontal ? parent.height : track.height * root.value
        color: ActiveTheme.colors["FG"]

        Behavior on width {
            enabled: root.growHorizontal && !mouseArea.pressed
            NumberAnimation { duration: root._animDuration; easing.type: root._easingType }
        }
        Behavior on height {
            enabled: !root.growHorizontal && !mouseArea.pressed
            NumberAnimation { duration: root._animDuration; easing.type: root._easingType }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: root.growHorizontal ? Qt.SizeHorCursor : Qt.SizeVerCursor
        preventStealing: true

        function updateValue(mouse) {
            let v = root.growHorizontal
                ? mouse.x / root.width
                : 1 - (mouse.y / root.height)
            root.value = Math.max(0, Math.min(1, v))
            root.setValue(root.value)
        }

        onPressed: (mouse) => updateValue(mouse)
        onPositionChanged: (mouse) => {
            if (pressed) updateValue(mouse)
        }
    }
}
