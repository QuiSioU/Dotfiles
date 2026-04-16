/* quickshell/widgets/TrayMenu.qml */


import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import "base/orbit"

OrbitMenu {
    id: trayMenu

    function rebuildEntries() {
        var list = []
        // .values is the reactive list view of the ObjectModel
        for (var i = 0; i < SystemTray.items.values.length; i++) {
            var item = SystemTray.items.values[i]
            list.push({
                name:    item.title || item.id || "",
                comment: item.tooltipDescription || "",
                icon:    item.icon || "",
                action: (function(captured) {
                    return function() { captured.activate() }
                })(item)
            })
        }
        entries = list
    }

    Component.onCompleted: rebuildEntries()

    // ObjectModel signals: objectInsertedPost / objectRemovedPost
    Connections {
        target: SystemTray.items
        function onObjectInsertedPost() { trayMenu.rebuildEntries() }
        function onObjectRemovedPost()  { trayMenu.rebuildEntries() }
    }

    // Per-item property changes
    Instantiator {
        model: SystemTray.items
        delegate: Connections {
            target: modelData
            function onTitleChanged()              { trayMenu.rebuildEntries() }
            function onIconChanged()               { trayMenu.rebuildEntries() }
            function onTooltipDescriptionChanged() { trayMenu.rebuildEntries() }
            function onReady()                     { trayMenu.rebuildEntries() }
        }
    }
}
