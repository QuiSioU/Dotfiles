/* quickshell/widgets/base/orbit/OrbitEntry.qml */



import QtQuick

QtObject {
    property string name:       ""
    property string icon:       ""
    property string comment:    ""
    property bool selected:     false
    property var action:        function() {}
}
