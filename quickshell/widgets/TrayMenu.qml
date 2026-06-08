/* quickshell/widgets/TrayMenu.qml */


import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import "base"

PanelWindow {
    id: root
    color: "transparent"
    visible: false
    focusable: true

    anchors {
        top: true;
        bottom: true;
        left: true;
        right: true
    }

    property bool _pendingOpen: false
    property int  _pendingSet:  0

    signal menuClosed()

    function openMenu(set_index) {
        console.log("openMenu called, trayMenu.sets.length =", trayMenu.sets.length)
        if (visible) return
        rebuildEntries()
        if (trayMenu.sets.length === 0) {
            _pendingOpen = true
            _pendingSet  = set_index ?? 0
            return
        }
        visible = true
        trayMenu.openMenu(set_index ?? 0)
    }

    function closeMenu() {
        if (!visible) return
        trayMenu.closeMenu()
    }

    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Instantiator {
        id: instantiator
        model: SystemTray.items
        delegate: QtObject {
            property string name:        modelData.tooltipTitle || modelData.id
            property string comment:     modelData.tooltipDescription
            property string icon:        modelData.icon
            property bool   selected:    true
            property bool   stateful:    false
            property var    leftAction:  function() { if (!modelData.onlyMenu) modelData.activate() }
            property var    rightAction: function() { if (modelData.hasMenu) modelData.display() }
        }
        onObjectRemoved: (index, obj) => root.rebuildEntries()
        onObjectAdded: (index, obj) => {
            root.rebuildEntries()
            if (root._pendingOpen && trayMenu.sets.length > 0) {
                root._pendingOpen = false
                root.visible = true
                trayMenu.openMenu(root._pendingSet)
            }
        }
    }

    function rebuildEntries() {
        console.log("rebuildEntries called, instantiator.count =", instantiator.count)
        let allEntries = []
        for (let i = 0; i < instantiator.count; i++)
            allEntries.push(instantiator.objectAt(i))
        console.log("allEntries.length =", allEntries.length)
        if (allEntries.length === 0) {
            root.closeMenu()
            return
        }

        let newSets = []
        for (let i = 0; i < allEntries.length; i += 8) {
            let chunk = allEntries.slice(i, i + 8)
            let set = Qt.createQmlObject('import QtQuick; QtObject { property list<QtObject> entries: [] }', root)
            set.entries = chunk
            newSets.push(set)
        }
        trayMenu.sets = newSets
        console.log("trayMenu.sets.length after rebuild =", trayMenu.sets.length)
    }

    // ── Menu ───────────────────────────────────────────────────────────────
    OrbitMenu {
        id: trayMenu
        onCloseRequested: {
            root.visible = false
            root.menuClosed()
        }

        Keys.onPressed: event => { if (event.key === Qt.Key_Tab) switchSet((activeSet + 1) % sets.length) }
        
        // ── Entry sets ────────────────────────────────────────────────────────────
        sets: []
    }
}
