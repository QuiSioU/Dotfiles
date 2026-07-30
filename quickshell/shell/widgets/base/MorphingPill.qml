/* quickshell/shell/widgets/base/MorphingPill.qml */

import QtQuick

Rectangle {
    id: root

    readonly property int _animDuration: 200
    readonly property int _fadeDuration: _animDuration / 2
    readonly property var _easingType: Easing.InOutCubic

    property Component content: null
    readonly property var item: _loaderAActive ? loaderA.item : loaderB.item
    signal morphFinished()

    // Non-animated shape toggle: false = pill (rounded), true = flat rectangle
    property real cornerRadius: 20
    property bool square: false
    radius: square ? 0 : cornerRadius

    clip: true

    property bool _morphing: false
    property bool _loaderAActive: true
    readonly property Loader _incomingLoader: _loaderAActive ? loaderB : loaderA
    readonly property Loader _outgoingLoader: _loaderAActive ? loaderA : loaderB

    onContentChanged: {
        _morphing = true
        _incomingLoader.sourceComponent = root.content
        _loaderAActive = !_loaderAActive
    }

    width:  item ? item.implicitWidth  : width
    height: item ? item.implicitHeight : height

    Behavior on width  { NumberAnimation {
        id: widthAnim
        duration: root._animDuration
        easing.type: root._easingType
    }}
    Behavior on height { NumberAnimation {
        id: heightAnim
        duration: root._animDuration
        easing.type: root._easingType
    }}

    function _checkFinished() {
        if (_morphing && !widthAnim.running && !heightAnim.running) {
            _morphing = false
            morphFinished()
        }
    }

    Connections { target: widthAnim;  function onRunningChanged() { root._checkFinished() } }
    Connections { target: heightAnim; function onRunningChanged() { root._checkFinished() } }

    Loader {
        id: loaderA
        anchors.fill: parent
        opacity: root._loaderAActive ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                id: fadeAnimA
                duration: root._fadeDuration
                easing.type: root._easingType
                onRunningChanged: if (!running && loaderA.opacity === 0) loaderA.sourceComponent = null
            }
        }
    }
    Loader {
        id: loaderB
        anchors.fill: parent
        opacity: root._loaderAActive ? 0 : 1
        Behavior on opacity {
            NumberAnimation {
                id: fadeAnimB
                duration: root._fadeDuration
                easing.type: root._easingType
                onRunningChanged: if (!running && loaderB.opacity === 0) loaderB.sourceComponent = null
            }
        }
    }
}
