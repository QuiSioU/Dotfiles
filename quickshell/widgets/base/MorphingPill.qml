/* quickshell/widgets/base/MorphingPill.qml */


import QtQuick

Rectangle {
    id: pill

    readonly property int animDuration: 600

    property Component content: null
    readonly property alias item: loader.item
    signal morphFinished()

    // Non-animated shape toggle: false = pill (rounded), true = flat rectangle
    property real cornerRadius: 20
    property bool square: false
    radius: square ? 0 : cornerRadius

    property bool _morphing: false
    onContentChanged: _morphing = true

    width:  loader.item ? loader.item.implicitWidth  : width
    height: loader.item ? loader.item.implicitHeight : height

    Behavior on width  { NumberAnimation {
        id: widthAnim
        duration: pill.animDuration
        easing.type: Easing.InOutCubic
    }}
    Behavior on height { NumberAnimation {
        id: heightAnim
        duration: pill.animDuration
        easing.type: Easing.InOutCubic
    }}

    function _checkFinished() {
        if (_morphing && !widthAnim.running && !heightAnim.running) {
            _morphing = false
            morphFinished()
        }
    }

    Connections { target: widthAnim;  function onRunningChanged() { pill._checkFinished() } }
    Connections { target: heightAnim; function onRunningChanged() { pill._checkFinished() } }

    Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: pill.content
    }
}
