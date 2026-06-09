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

    function openMenu(set_index, posX, posY) {
        console.log("openMenu called, trayMenu.sets.length =", trayMenu.sets.length)
        if (visible) return
        rebuildEntries()
        if (trayMenu.sets.length === 0) {
            _pendingOpen = true
            _pendingSet  = set_index ?? 0
            return
        }
        visible = true
        trayMenu.openMenu(set_index ?? 0, posX, posY)
    }

    function closeMenu() {
        if (!visible) return
        trayMenu.closeMenu()
    }

    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Timer {
        id: rebuildDebounce
        interval: 50
        repeat: false
        onTriggered: {
            let wasOpen = root.visible
            let currentSet = trayMenu.activeSet

            if (wasOpen) root.visible = false  // bypass animation

            root.rebuildEntries()

            if (root._pendingOpen && trayMenu.sets.length > 0) {
                root._pendingOpen = false
                root.visible = true
                trayMenu.openMenu(root._pendingSet)
            } else if (wasOpen && trayMenu.sets.length > 0) {
                let safeSet = Math.min(currentSet, trayMenu.sets.length - 1)
                root.visible = true
                trayMenu.openMenu(safeSet)
            }
        }
    }

    QsMenuOpener {
        id: menuOpener
        menu: null  // set dynamically on right click

        property real pendingX: 0
        property real pendingY: 0

        onChildrenChanged: {
            if (menu === null) return
            if (children.values.length === 0) return
            root.buildOptionSets(children)
            optionMenu.openMenu(0, pendingX, pendingY)
        }
    }

    OrbitMenu {
        id: optionMenu
        sets: []
        onCloseRequested: {
            optionMenu.sets = []
            menuOpener.menu = null
            trayMenu.forceActiveFocus()
        }
    }

    function buildOptionSets(entries) {
        let values = entries.values
        console.log("buildOptionSets called, values.length =", values.length)
        let allEntries = []
        for (let i = 0; i < values.length; i++) {
            let e = values[i]
            console.log("entry:", e.text, "separator:", e.isSeparator)
            if (e.isSeparator) continue
            allEntries.push(Qt.createQmlObject(`
                import QtQuick
                QtObject {
                    property string name:     ""
                    property string comment:  ""
                    property string icon:     ""
                    property bool   selected: false
                    property bool   stateful: false
                    property var    leftAction:  null
                    property var    rightAction: null
                }
            `, root))
            let obj = allEntries[allEntries.length - 1]
            obj.name       = e.text
            obj.icon       = e.icon
            obj.leftAction = function() { e.triggered() }
            obj.rightAction = e.hasChildren ? function() { /* nested, later */ } : null
        }
        console.log("allEntries built:", allEntries.length)

        let newSets = []
        for (let i = 0; i < allEntries.length; i += 8) {
            let set = Qt.createQmlObject('import QtQuick; QtObject { property list<QtObject> entries: [] }', root)
            set.entries = allEntries.slice(i, i + 8)
            newSets.push(set)
        }
        optionMenu.sets = newSets
        console.log("optionMenu.sets.length =", optionMenu.sets.length)
    }

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
            property var rightAction: function(index, total) {
                if (!modelData.hasMenu) return
                let pos = trayMenu.bubbleCenter(index, total)
                menuOpener.pendingX = pos.x
                menuOpener.pendingY = pos.y
                menuOpener.menu = modelData.menu
            }
        }
        onObjectRemoved:    (index, obj) => rebuildDebounce.restart()
        onObjectAdded:      (index, obj) => rebuildDebounce.restart()
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
