/* quickshell/widgets/QuickAppsMenu.qml */


import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "base"
import "user"

PanelWindow {
    id: root
    color: "transparent"
    visible: false
    focusable: true

    property var _sets: []

    anchors {
        top: true;
        bottom: true;
        left: true;
        right: true
    }

    signal menuClosed()

    function openMenu(set_index, posX, posY) {
        if (visible) return
        visible = true
        orbitMenu.openMenu(set_index ?? 0, posX, posY)
    }

    function closeMenu() {
        if (!visible) return
        orbitMenu.closeMenu()
    }

    function makeEntry(app) {
        var obj = Qt.createQmlObject(`import QtQuick; QtObject {
            property string name
            property string id
            property string icon
            property string comment
            property bool   selected
            property bool   stateful
            property var leftAction
        }`, root)
        obj.name    = app.name
        obj.id      = app.id ?? ""
        obj.icon    = app.icon ? "image://icon/" + app.icon : ""
        obj.comment = app.comment ?? ""
        obj.selected = app.selected ?? true
        obj.stateful = app.stateful ?? false
        obj.leftAction = (function(a) { return () => a.execute() })(app)
        return obj
    }

    function rebuildSets() {
        var entries = DesktopEntries.applications.values
            .filter(app => !app.noDisplay)
            .filter(app => QuickAppsList.apps.includes(app.id))
            .map(app => makeEntry(app))
            .sort((a, b) => QuickAppsList.apps.indexOf(a.id) - QuickAppsList.apps.indexOf(b.id))

        if (entries.length === 0) return

        var sets = []
        for (var i = 0; i < entries.length; i += 8) {
            var setObj = Qt.createQmlObject('import QtQuick; QtObject { property var entries: [] }', root)
            setObj.entries = entries.slice(i, i + 8)
            sets.push(setObj)
        }

        root._sets = sets
    }

    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // ── Hooks ─────────────────────────────────────────────────────────────────
    Component.onCompleted: rebuildSets()
    Connections {
        target: DesktopEntries
        function onApplicationsChanged() { if (root._sets.length === 0) root.rebuildSets() }
    }

    // ── Menu ───────────────────────────────────────────────────────────────
    OrbitMenu {
        id: orbitMenu
        onCloseRequested: {
            root.visible = false
            root.menuClosed()
        }
        z: 200
        sets: root._sets
    }
}
