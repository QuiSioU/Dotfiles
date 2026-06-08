/* quickshell/widgets/TrayMenu.qml */


import QtQuick
import Quickshell
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

    signal menuClosed()

    function openMenu(set_index) {
        if (visible) return
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
        onObjectAdded:   (index, obj) => rebuildEntries()
        onObjectRemoved: (index, obj) => rebuildEntries()
    }

    function rebuildEntries() {
        let allEntries = []
        for (let i = 0; i < instantiator.count; i++)
            allEntries.push(instantiator.objectAt(i))

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
