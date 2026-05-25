/* quickshell/widgets/ControlDrawer.qml */


import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import ElyseanShell.Services
import ElyseanShell.Themes
import "base"

Drawer {
    id: drawer

    edge:          Drawer.Edge.Bottom
    blobColor:     ActiveTheme.color["BG"]
    blobSmoothing: 36
    blobRadius:    18

    property var _entries: []
    property var _modes:   []
    property var _wallpaperFiles: []

    Process {
        id: wallpaperScanner
        command: ["find",
            Quickshell.env("HOME") + "/.config/elysean_themes/wallpapers/",
            "-type", "f",
            "(",
            "-iname", "*.jpg", "-o",
            "-iname", "*.jpeg", "-o",
            "-iname", "*.png", "-o",
            "-iname", "*.webp",
            ")"
        ]
        stdout: SplitParser {
            onRead: function(line) {
                if (line.trim() !== "")
                    drawer._wallpaperFiles.push(line.trim())  // ← _wallpaperFiles
            }
        }
        onExited: {
            drawer._wallpaperFiles = [...drawer._wallpaperFiles]
        }
    }

    Process {
        id: wpProcess
        running: false
    }

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() { drawer.rebuildEntries() }
    }

    Connections {
        target: BluetoothDeviceModel
        function onDataChanged() { searchView.refresh() }
        function onModelReset()  { searchView.refresh() }
    }

    Connections {
        target: drawer
        function onVisibleChanged() {
            if (drawer.visible) {
                searchView.forceInputFocus()
                drawer._wallpaperFiles = []
                wallpaperScanner.running = false
                wallpaperScanner.running = true
            } else {
                searchView.clearInput()
            }
        }
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
            {  /* Bluetooth */
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
            },
            {  /* Wallpaper manager */
                prefix:      "wallpaper",
                label:       "Wallpaper",
                placeholder: "Select image to set as wallpaper",
                icon:        Quickshell.shellDir + "/assets/icons/notification-bell.svg",
                entries: function() {
                    const dir = Quickshell.env("HOME") + "/.config/elysean_themes/wallpapers/"
                    return _wallpaperFiles.map(f => ({
                        name:    f.replace(/.*\//, "").replace(/\.[^.]+$/, ""), // filename without ext
                        comment: f,
                        icon:    f,
                        action:  (function(path) {
                            return () => {
                                wpProcess.running = true
                                wpProcess.command = [
                                    "awww", "img", path,
                                    "--transition-type", "center"
                                ]
                            }
                        })(f)
                    }))
                }
            }
        ]
    }

    // ── Hooks ─────────────────────────────────────────────────────────────────
    Component.onCompleted: {
        rebuildEntries()
        rebuildModes()
    }

    // ── Content ───────────────────────────────────────────────────────────────
    SearchView {
        id: searchView

        anchors.centerIn: parent

        width:   750
        height:  500
        spacing: 12

        entries:      drawer._entries
        modes:        drawer._modes

        onCloseRequested: drawer.close()
    }
}
