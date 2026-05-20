/* quickshell/widgets/ControlCenter.qml */


import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import ElyseanShell.Services
import ElyseanShell.Themes
import "base"

PanelWindow {
    id: launcher_panwin

    implicitWidth: 750
    implicitHeight: 500
    color: "transparent"
    focusable: true
    visible: false

    property var _entries: []
    property var _modes:   []
    property var _wallpaperFiles: []

    Process {
        id: wallpaperScanner
        command: [
            "find",
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
                    launcher_panwin._wallpaperFiles.push(line.trim())  // ← _wallpaperFiles
            }
        }
        onExited: {
            launcher_panwin._wallpaperFiles = [...launcher_panwin._wallpaperFiles]
        }
    }

    Process {
        id: wpProcess
        running: false
    }

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() { launcher_panwin.rebuildEntries() }
    }

    Connections {
        target: BluetoothDeviceModel
        function onDataChanged() { searchView.refresh() }
        function onModelReset()  { searchView.refresh() }
    }

    function close() {
        launcher_panwin.visible = false
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
                                wpProcess.environment = ({
                                    "XDG_CACHE_HOME": Quickshell.env("$AWWW_CACHE_HOME"),
                                })
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

    onVisibleChanged: {
        if (visible) {
            searchView.forceInputFocus()
            _wallpaperFiles = []
            wallpaperScanner.running = false
            wallpaperScanner.running = true
        }
        else
            searchView.clearInput()
    }

    HyprlandFocusGrab {
        windows: [ launcher_panwin ]
        active: launcher_panwin.visible
        onCleared: launcher_panwin.visible = false
    }

    // ── Content ───────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"
        radius: 12
        clip: true

        SearchView {
            id: searchView

            anchors.fill: parent 

            entries:      launcher_panwin._entries
            modes:        launcher_panwin._modes

            onCloseRequested: launcher_panwin.close()
        }
    }
}
