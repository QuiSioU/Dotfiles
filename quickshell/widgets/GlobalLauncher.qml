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
    // Command modes — each appears when you type ">" in the launcher.
    //
    // Structure:
    //   prefix   — what you type after ">", e.g. "bt" → ">bt "
    //   label    — human-readable name shown in the mode list
    //   icon     — XDG icon name (falls back to a letter if not found)
    //   entries  — array OR function returning array of LauncherEntry-like objects
    //
    // To add more modes, just push another object into this array.
    // ----------------------------------------------------------------
    function rebuildModes() {
        modes = [
            {
                prefix: "bt",
                label: "Bluetooth",
                icon: Quickshell.shellDir + "/assets/icons/bluetooth-active.svg",
                entries: function() {
                    return BluetoothDeviceModel.deviceList().map(dev => ({
                        name:    dev.alias || dev.name,
                        icon:    dev.icon || "",
                        comment: dev.address + " · " + (dev.connected ? "Connected ✓" : "Disconnected"),
                        action:  (function(p) {
                            return () => BluetoothDeviceModel.toggle(p)
                        })(dev.path),
                        stayOpen: true
                    }))
                }
            },

            // {
            //     prefix: "wall",
            //     label: "Wallpaper",
            //     icon: "image",
            //     entries: function() {
            //         // Replace wallpaperList with however you expose wallpapers.
            //         // Example assumes a Wallpapers singleton with a `list` of { path, name }.
            //         if (typeof Wallpapers !== "undefined") {
            //             return Wallpapers.list.map(w => ({
            //                 name: w.name ?? w.path.split("/").pop(),
            //                 icon: "image-x-generic",
            //                 comment: w.path,
            //                 action: (function(p) {
            //                     return () => Wallpapers.setWallpaper(p)
            //                 })(w.path)
            //             }))
            //         }
            //         return [{ name: "Wallpapers unavailable", icon: "image-missing", comment: "Wallpapers singleton not found", action: () => {} }]
            //     }
            // },

            // {
            //     prefix: "theme",
            //     label: "Color Theme",
            //     icon: "preferences-desktop-theme",
            //     entries: [
            //         {
            //             name: "Dark",
            //             icon: "weather-clear-night",
            //             comment: "Switch to dark mode",
            //             action: () => { console.log("Changed to dark mode") }
            //         },
            //         {
            //             name: "Light",
            //             icon: "weather-clear",
            //             comment: "Switch to light mode",
            //             action: () => { console.log("Changed to light mode") }
            //         },
            //         {
            //             name: "System",
            //             icon: "preferences-system",
            //             comment: "Follow system theme",
            //             action: () => { console.log("Changed to system mode") }
            //         }
            //     ]
            // },

            // ---- Add modes below ----
            // {
            //     prefix: "pw",
            //     label: "Power",
            //     icon: "system-shutdown",
            //     entries: [
            //         { name: "Shutdown",  icon: "system-shutdown", comment: "Power off the machine", action: () => Qt.callLater(() => { /* your command */ }) },
            //         { name: "Reboot",    icon: "system-reboot",   comment: "Restart the machine",   action: () => Qt.callLater(() => { /* your command */ }) },
            //         { name: "Suspend",   icon: "system-suspend",  comment: "Sleep",                 action: () => Qt.callLater(() => { /* your command */ }) },
            //     ]
            // },
        ]
    }
}
