import QtQuick
import ElyseanShell.Services
import "Base"

Launcher {
    id: root

    function rebuildEntries() {
        const devices = BluetoothDeviceModel.deviceList()
        console.log("Devices:", JSON.stringify(devices))
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
