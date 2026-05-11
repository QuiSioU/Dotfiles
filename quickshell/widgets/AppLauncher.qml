/* quickshell/widgets/GlobalLauncher.qml */


import Quickshell
import QtQuick
import ElyseanShell.Services
import "base/drawer"
import "base/launcher"

Drawer {
    id: root

    edge:          Drawer.Edge.Bottom
    blobColor:     "#4488ff"
    blobSmoothing: 36
    blobRadius:    18

    // ── Open / close hooks ────────────────────────────────────────────────────
    onVisibleChanged: {
        if (visible)
            searchBar.forceInputFocus()
        else
            searchBar.clearInput()
    }

    // ── Content ───────────────────────────────────────────────────────────────
    Column {
        width:   750
        height:  500
        spacing: 12

        SearchBar {
            id: searchBar
            width:  parent.width
            height: 56

            entries:      root._entries
            modes:        root._modes
            actionPrefix: "/"

            onCloseRequested: root.visible = false

            onNavigated: function(index) {
                resultsList.positionAt(index)
            }

            onActivated: {
                const entry = searchBar.filteredEntries[searchBar.currentIndex]
                if (!entry) return
                entry.action()
                if (!entry.stayOpen) root.visible = false
            }
        }

        ResultList {
            id: resultsList
            width:  parent.width
            height: parent.height - searchBar.height - parent.spacing

            model:        searchBar.filteredEntries
            currentIndex: searchBar.currentIndex

            onActivated: function(entry) {
                entry.action()
            }

            onCloseRequested: root.visible = false
        }
    }

    // ── Internal data ─────────────────────────────────────────────────────────
    property var _entries: []
    property var _modes:   []

    Component.onCompleted: {
        rebuildEntries()
        rebuildModes()
    }

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() { root.rebuildEntries() }
    }

    Connections {
        target: BluetoothDeviceModel
        function onDataChanged() { root.searchBar.refresh() }
        function onModelReset()  { root.searchBar.refresh() }
    }

    // ── App entries ───────────────────────────────────────────────────────────
    function rebuildEntries() {
        _entries = DesktopEntries.applications.values
            .filter(app => !app.noDisplay)
            .map(app => ({
                name:    app.name,
                icon:    app.icon ?? "",
                comment: app.comment ?? "",
                action:  (function(a) { return () => a.execute() })(app)
            }))
            .sort((a, b) => a.name.localeCompare(b.name))
    }

    // ── Command modes ─────────────────────────────────────────────────────────
    function rebuildModes() {
        _modes = [
            {
                prefix:      "bluetooth",
                label:       "Bluetooth",
                placeholder: "Select device to toggle connection",
                icon:        Quickshell.shellDir + "/assets/icons/bluetooth-active.svg",
                entries: function() {
                    return BluetoothDeviceModel.deviceList().map(dev => ({
                        name:    dev.alias || dev.name,
                        icon:    dev.icon || "",
                        comment: dev.address + " · " + (dev.connected ? "Connected ✓" : "Disconnected"),
                        action:  (function(p) {
                            return () => BluetoothDeviceModel.toggle(p)
                        })(dev.path)
                    }))
                }
            }
        ]
    }
}
