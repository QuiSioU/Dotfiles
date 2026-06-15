/* quickshell/widgets/ControlCenter.qml */


import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Wayland
import ElysianShell.Services
import ElysianShell.Themes
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
    property var _colorThemeFiles: []

    Process {
        id: wallpaperScanner
        command: [
            "find",
            Quickshell.env("HOME") + "/.config/awww/",
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
        id: colorThemeScanner
        command: [
            "find",
            Quickshell.env("HOME") + "/.config/elysian_themes/themes/",
            "-type", "f",
            "(",
            "-iname", "*.toml",
            ")"
        ]
        stdout: SplitParser {
            onRead: function(line) {
                if (line.trim() !== "")
                    launcher_panwin._colorThemeFiles.push(line.trim())  // ← _colorThemeFiles
            }
        }
        onExited: {
            launcher_panwin._colorThemeFiles = [...launcher_panwin._colorThemeFiles]
        }
    }

    Process {
        id: wpProcess
        running: false
    }

    Process {
        id: ctProcess
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
                icon:        Quickshell.shellDir + "/assets/images/preferences-desktop-wallpaper.svg",
                entries: function() {
                    return _wallpaperFiles.map(f => ({
                        name:    f.replace(/.*\//, "").replace(/\.[^.]+$/, ""), // filename without ext
                        comment: f,
                        icon:    f,
                        action:  (function(path) {
                            return () => {
                                wpProcess.command = [
                                    "awww", "img", path,
                                    "--transition-type", "center"
                                ]
                                wpProcess.running = true
                            }
                        })(f)
                    }))
                }
            },
            {  /* Color theme manager */
                prefix:      "color-theme",
                label:       "Color Theme",
                placeholder: "Select a color theme",
                icon:        Quickshell.shellDir + "/assets/images/color-palette.svg",
                entries: function() {
                    return _colorThemeFiles.map(f => ({
                        name:    f.replace(/.*\//, "").replace(/\.[^.]+$/, ""), // filename without ext
                        comment: f,
                        icon:    Quickshell.shellDir + "/assets/images/preferences-desktop-color",
                        action:  (function(path) {
                            return () => {
                                ctProcess.command = [
                                    "python3",
                                    Quickshell.env("HOME") + "/.config/elysian_themes/set_theme.py",
                                    path
                                ]
                                ctProcess.running = true
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

            _colorThemeFiles = []
            colorThemeScanner.running = false
            colorThemeScanner.running = true
        }
        else
            searchView.clearInput()
    }

    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // ── Content ───────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: ActiveTheme.colors["BG"]
        radius: 12
        clip: true

        border.width: 2
        border.color: ActiveTheme.colors["FG_DARK"]

        SearchView {
            id: searchView

            anchors.fill: parent 

            entries:      launcher_panwin._entries
            modes:        launcher_panwin._modes

            onCloseRequested: launcher_panwin.close()
        }
    }
}
