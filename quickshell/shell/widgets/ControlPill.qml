/* quickshell/shell/widgets/ControlPill.qml */


import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import ElysianShell.Services
import ElysianShell.Themes
import "base"

MorphingPill {
    id: root

    property var targetScreen: null
    property string pillWidget: "clock"
    property real clockHeight: 0

    property var _entries: []
    property var _launchModes:   []
    property var _wallpaperFiles: []
    property var _colorThemeFiles: []

    color: ActiveTheme.colors["BG"]

    // ── Public API ────────────────────────────────────────────────────────────
    function toggleLauncher(): void { pillWidget = pillWidget === "launcher" ? "clock" : "launcher" }
    function lockSession(): void { pillWidget = "lock" }
    function reset(): void { pillWidget = "clock" }

    // ── Processes ─────────────────────────────────────────────────────────────
    Process {
        id: wallpaperScanner
        command: [
            "bash", "-c",
            "find " + Quickshell.env("HOME") + "/.config/awww/ -type f " +
            "\\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) " +
            "-exec realpath {} \\;"
        ]
        stdout: SplitParser {
            onRead: function(line) {
                if (line.trim() !== "")
                    root._wallpaperFiles.push(line.trim())  // ← _wallpaperFiles
            }
        }
        onExited: {
            root._wallpaperFiles = [...root._wallpaperFiles]
            LockService.refreshWallpaper()
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
                root._colorThemeFiles.push({ path: path, name: name })
            }
        }
        onExited: {
            root._colorThemeFiles = [...root._colorThemeFiles]
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

    // ── Possible Menus ────────────────────────────────────────────────────────
    Component {
        id: clockMenu;
        Item {
            id: clockRoot

            property real horizontalPadding: 10
            property real verticalPadding: 4

            implicitWidth: clock.implicitWidth + horizontalPadding * 2
            implicitHeight: clock.implicitHeight + verticalPadding * 2

            Text {
                id: clock
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: 18
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

            readonly property int padding: 20
            implicitWidth:  contentColumn.implicitWidth  + padding * 2
            implicitHeight: contentColumn.implicitHeight + padding * 2

            color: "transparent"

            Connections {
                target: DesktopEntries
                function onApplicationsChanged() { controlRect.rebuildEntries() }
            }

            Connections {
                target: BluetoothDeviceModel
                function onDataChanged() { searchBar.refresh() }
                function onModelReset()  { searchBar.refresh() }
            }

            Connections {
                target: wallpaperScanner
                function onExited() { searchBar.refresh() }
            }

            Connections {
                target: colorThemeScanner
                function onExited() { searchBar.refresh() }
            }

            function close() { root.pillWidget = "clock" }

            // ── App entries ───────────────────────────────────────────────────────────
            function rebuildEntries() {
                root._entries = DesktopEntries.applications.values
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
            function rebuildLaunchModes() {
                root._launchModes = [
                    {  /* Bluetooth */
                        prefix:      "bluetooth",
                        label:       "Bluetooth",
                        placeholder: "Select device to toggle connection",
                        icon:        Quickshell.shellDir + "/assets/icons/bluetooth-active.svg",
                        displayMode: "items",
                        entries: function() {
                            return BluetoothDeviceModel.deviceList().map(dev => ({
                                name:    dev.alias || dev.name,
                                icon:    dev.icon ? "image://icon/" + dev.icon : "",
                                comment: dev.address + " · " + (dev.connected ? "Connected ✓" : "Disconnected"),
                                stayOpen: true,
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
                        displayMode: "carousel",
                        entries: function() {
                            const current = LockService.currentWallpaper.replace(/^file:\/\//, "")
                            const idx = root._wallpaperFiles.indexOf(current)
                            const files = idx > 0
                                ? [...root._wallpaperFiles.slice(idx), ...root._wallpaperFiles.slice(0, idx)]
                                : root._wallpaperFiles
                            
                            return files.map(f => ({
                                name:    f.replace(/.*\//, "").replace(/\.[^.]+$/, ""), // filename without ext
                                comment: f,
                                icon:    f,
                                action:  (function(path) {
                                    return () => {
                                        wpProcess.command = [
                                            "awww", "img", path,
                                            "--transition-type", "fade",
                                            "--transition-duration", "1"
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
                        displayMode: "items",
                        entries: function() {
                            return root._colorThemeFiles.map(entry => ({
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
                rebuildLaunchModes()
                Qt.callLater(searchBar.forceInputFocus)

                root._wallpaperFiles = []
                wallpaperScanner.running = true

                root._colorThemeFiles = []
                colorThemeScanner.running = true

                LockService.refreshWallpaper()
            }

            // ── Content ───────────────────────────────────────────────────────────────
            Rectangle {
                anchors.fill: parent
                color: ActiveTheme.colors["BG"]
                radius: root.radius
                clip: true

                border.width: 2
                border.color: ActiveTheme.colors["FG_DARK"]

                ColumnLayout {
                    id: contentColumn
                    anchors.centerIn: parent
                    spacing: 20

                    SearchBar {
                        id: searchBar
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        entries: root._entries
                        launchModes:   root._launchModes
                        wrapNavigation: searchBar.activeMode?.displayMode === "carousel"
                        onNavigated:      (index) => resultView.positionAt(index)
                        onActivated:      (entry) => entry.action()
                        onCloseRequested: controlRect.close()
                    }

                    ResultView {
                        id: resultView
                        Layout.alignment: Qt.AlignHCenter
                        model:        searchBar.filteredEntries
                        currentIndex: searchBar.currentIndex
                        displayMode:         searchBar.activeMode?.displayMode ?? "items"
                        onActivated:      (entry) => entry.action()
                        onCloseRequested: controlRect.close()
                    }
                }
            }
        }
    }
    Component {
        id: lockDecoy
        LockVisual {
            implicitWidth:  root.targetScreen ? root.targetScreen.width  : 0
            implicitHeight: root.targetScreen ? root.targetScreen.height : 0
            wallpaper: LockService.currentWallpaper   // shared source, see note below
        }
    }
    LockScreen { id: lockScreen }

    onPillWidgetChanged: {
        switch (pillWidget) {
            case "lock":        root.content = lockDecoy; break
            case "launcher":    root.content = controlCenter; break
            default:            root.content = clockMenu; break
        }
    }
    Component.onCompleted: root.content = clockMenu

    // ── Morph handoff ────────────────────────────────────────────────────
    Connections {
        target: root
        function onMorphFinished() {
            if (root.pillWidget === "clock") root.clockHeight = root.height
            if (root.pillWidget === "lock" && !lockScreen.isLocked) {
                root.square = true
                lockScreen.lock()   // decoy is fully fullscreen now — safe to hand off
            }
        }
    }

    Connections {
        target: lockScreen
        function onReadyToUnlock() {
            root.square = false
            lockScreen.unlock()      // decoy still fullscreen underneath — no flash
            root.pillWidget = "clock"    // now shrink back down
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
    }
}
