/* quickshell/widgets/TopBar.qml */


import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Wayland
import ElysianShell.Services
import ElysianShell.Themes
import "base"

PanelWindow {
    id: root
    readonly property int topbarHeight: 40

    implicitWidth: screen.width
    implicitHeight: screen.height
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: topbarHeight

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: currentMode === "clock" ? WlrKeyboardFocus.None : WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "top-bar"

    mask: Region { item: mainPill }

    anchors { top: true; right: true; left: true }
    color: "transparent"
    focusable: true

    property string currentMode: "clock"

    // ── Possible Menus ────────────────────────────────────────────────────────
    Component {
        id: clockMenu;
        Item {
            id: clockRoot
            implicitWidth: clock.implicitWidth + 32
            implicitHeight: clock.implicitHeight + 12

            Text {
                id: clock
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: 20
                font.bold: true
                text: Qt.formatTime(new Date(), "hh:mm")
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: clock.text = Qt.formatTime(new Date(), "hh:mm")
                }
            }
        }
    }
    Component {
        id: controlCenter
        Rectangle {
            id: controlRect

            implicitWidth: 750
            implicitHeight: 500
            color: "transparent"

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
                            controlRect._wallpaperFiles.push(line.trim())  // ← _wallpaperFiles
                    }
                }
                onExited: {
                    controlRect._wallpaperFiles = [...controlRect._wallpaperFiles]
                }
            }

            Process {
                id: colorThemeScanner
                command: [
                    Quickshell.shellDir + "/scripts/parse_color_themes.sh",
                    Quickshell.env("HOME") + "/.config/elysian_themes/themes"
                ]
                stdout: SplitParser {
                    onRead: function(line) {
                        if (line.trim() === "") return
                        const parts = line.split("\t")
                        const path = parts[0]
                        const name = (parts.length > 1 && parts[1].trim() !== "")
                            ? parts[1]
                            : path.replace(/.*\//, "").replace(/\.[^.]+$/, "")
                        controlRect._colorThemeFiles.push({ path: path, name: name })
                    }
                }
                onExited: {
                    controlRect._colorThemeFiles = [...controlRect._colorThemeFiles]
                }
            }

            Process {
                id: wpProcess
                running: false
            }

            Process {
                id: vscPackageProcess
                running: false
            }

            Process {
                id: vscProcess
                running: false
                onExited: vscPackageProcess.running = true
            }

            Process {
                id: ctProcess
                running: false
                onExited: vscProcess.running = true
            }

            Connections {
                target: DesktopEntries
                function onApplicationsChanged() { controlRect.rebuildEntries() }
            }

            Connections {
                target: BluetoothDeviceModel
                function onDataChanged() { searchView.refresh() }
                function onModelReset()  { searchView.refresh() }
            }

            function close() { root.currentMode = "clock" }

            // ── App entries ───────────────────────────────────────────────────────────
            function rebuildEntries() {
                _entries = DesktopEntries.applications.values
                    .filter(app => !app.noDisplay)
                    .map(app => ({
                        name:    app.name,
                        icon:    app.icon ? "image://icon/" + app.icon : "",
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
                                icon:    dev.icon ? "image://icon/" + dev.icon : "",
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
                            return _colorThemeFiles.map(entry => ({
                                name:    entry.name, // filename without ext
                                comment: entry.path,
                                icon:    Quickshell.shellDir + "/assets/images/preferences-desktop-color",
                                action:  (function(path) {
                                    return () => {
                                        vscPackageProcess.command = [
                                            "python3",
                                            Quickshell.env("HOME") + "/.config/vscodium/build_package.py"
                                        ]
                                        vscProcess.command = [
                                            "python3",
                                            Quickshell.env("HOME") + "/.config/vscodium/build_theme.py",
                                            path
                                        ]
                                        ctProcess.command = [
                                            "python3",
                                            Quickshell.env("HOME") + "/.config/elysian_themes/set_theme.py",
                                            path
                                        ]
                                        ctProcess.running = true
                                    }
                                })(entry.path)
                            }))
                        }
                    }
                ]
            }

            // ── Hooks ─────────────────────────────────────────────────────────────────
            Component.onCompleted: {
                rebuildEntries()
                rebuildModes()
                searchView.forceInputFocus()
            }

            // ── Content ───────────────────────────────────────────────────────────────
            Rectangle {
                anchors.fill: parent
                color: ActiveTheme.colors["BG"]
                radius: mainPill.radius
                clip: true

                border.width: 2
                border.color: ActiveTheme.colors["FG_DARK"]

                SearchView {
                    id: searchView

                    anchors.fill: parent
                    z: 100

                    entries:      controlRect._entries
                    modes:        controlRect._modes

                    onCloseRequested: controlRect.close()
                }
            }
        }
    }
    Component {
        id: lockDecoy
        LockVisual {
            implicitWidth: screen.width
            implicitHeight: screen.height
            wallpaper: LockService.currentWallpaper   // shared source, see note below
        }
    }
    LockScreen { id: lockScreen }

    onCurrentModeChanged: {
        switch (currentMode) {
            case "lock":        mainPill.content = lockDecoy; break
            case "launcher":    mainPill.content = controlCenter; break
            default:            mainPill.content = clockMenu; break
        }
    }
    Component.onCompleted: mainPill.content = clockMenu

    // ── Morph handoff ────────────────────────────────────────────────────
    Connections {
        target: mainPill
        function onMorphFinished() {
            if (root.currentMode === "lock" && !lockScreen.isLocked) {
                mainPill.square = true
                lockScreen.lock()   // decoy is fully fullscreen now — safe to hand off
            }
        }
    }

    Connections {
        target: lockScreen
        function onReadyToUnlock() {
            mainPill.square = false
            lockScreen.unlock()      // decoy still fullscreen underneath — no flash
            root.currentMode = "clock"    // now shrink back down
        }
    }

    // ── Content ───────────────────────────────────────────────────────────────
    MorphingPill {
        id: mainPill
        color: ActiveTheme.colors["BG"]
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: root.topbarHeight / 10
        }
        cornerRadius: root.topbarHeight / 2
    }

    IpcHandler {
        target: "topbar"
        function openLauncher(): void {
            root.currentMode = root.currentMode === "launcher" ? "clock" : "launcher"
        }
        function lockSession(): void { root.currentMode = "lock" }
        function reset(): void { root.currentMode = "clock" }
    }
}
