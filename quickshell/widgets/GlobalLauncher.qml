/* quickshell/widgets/GlobalLauncher.qml */


import Quickshell
import QtQuick
import ElyseanShell.Services
import "base/launcher"

LauncherMenu {
    id: root

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
        function onDataChanged() { root.refresh() }
        function onModelReset()  { root.refresh() }
    }

    // ----------------------------------------------------------------
    // App entries (normal mode)
    // ----------------------------------------------------------------
    function rebuildEntries() {
        entries = DesktopEntries.applications.values
            .filter(app => !app.noDisplay)
            .map(app => ({
                name: app.name,
                icon: app.icon ?? "",
                comment: app.comment ?? "",
                action: (function(a) { return () => a.execute() })(app)
            }))
            .sort((a, b) => a.name.localeCompare(b.name))
    }

    // ----------------------------------------------------------------
    // Command modes — each appears when you type "/" in the launcher.
    // ----------------------------------------------------------------
    function rebuildModes() {
        modes = [
            {
                prefix: "bluetooth",
                label: "Bluetooth",
                placeholder: "Select device to toggle connection",
                icon: Quickshell.shellDir + "/assets/icons/bluetooth-active.svg",
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
