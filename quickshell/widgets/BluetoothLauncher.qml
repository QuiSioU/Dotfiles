/* widgets/BluetoothLauncher.qml */

import QtQuick
import ElyseanShell.Services
import "base/launcher"

Launcher {
    id: root

    function rebuildEntries() {
        entries = BluetoothDeviceModel.deviceList().map(dev => ({
            name:    dev.alias || dev.name,
            icon:    dev.icon || "",
            comment: dev.address + " · " + (dev.connected ? "Connected" : "Disconnected"),
            action:  (function(p) {
                return () => BluetoothDeviceModel.toggle(p)
            })(dev.path)
        }))
    }

    Component.onCompleted: rebuildEntries()

    Connections {
        target: BluetoothDeviceModel
        function onDataChanged() { root.rebuildEntries() }
        function onModelReset()  { root.rebuildEntries() }
    }
}
