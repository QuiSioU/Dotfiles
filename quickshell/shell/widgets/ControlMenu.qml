/* quickshell/shell/widgets/ControlMenu.qml */


import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import ElysianShell.Services
import ElysianShell.Themes
import "base"

PanelWindow {
    id: panwin
    readonly property int topbarHeight: 40

    implicitWidth: screen.width
    implicitHeight: screen.height
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: topbarHeight

    WlrLayershell.layer: controlPill.pillWidget !== "clock" ? WlrLayer.Overlay : WlrLayer.Top
    WlrLayershell.keyboardFocus: controlPill.pillWidget === "launcher" || controlPill.pillWidget === "lock"
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None
    WlrLayershell.namespace: "top-bar"

    mask: Region { item: controlPill }

    anchors { top: true; right: true; left: true }
    color: "transparent"
    
    focusable: true

    // ── Content ───────────────────────────────────────────────────────────────
    MorphingPill {
        id: controlPill

        property var targetScreen: null
        property string pillWidget: "clock"
        property real clockHeight: 0

        property var _entries: []
        property var _launchModes:   []
        property var _wallpaperFiles: []
        property var _colorThemeFiles: []

        readonly property int _menuHideTimer: 1000

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: (panwin.topbarHeight - controlPill.clockHeight) / 2
        }
        color: ActiveTheme.colors["BG"]
        cornerRadius: panwin.topbarHeight / 2

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
                        controlPill._wallpaperFiles.push(line.trim())  // ← _wallpaperFiles
                }
            }
            onExited: {
                controlPill._wallpaperFiles = [...controlPill._wallpaperFiles]
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
                    controlPill._colorThemeFiles.push({ path: path, name: name })
                }
            }
            onExited: {
                controlPill._colorThemeFiles = [...controlPill._colorThemeFiles]
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

        Timer {
            id: volumeOsdTimer
            interval: controlPill._menuHideTimer
            onTriggered: if (controlPill.pillWidget === "volume") controlPill.pillWidget = "clock"
        }

        Timer {
            id: brightnessOsdTimer
            interval: controlPill._menuHideTimer
            onTriggered: if (controlPill.pillWidget === "brightness") controlPill.pillWidget = "clock"
        }

        Timer {
            id: workspaceTimer
            interval: controlPill._menuHideTimer
            onTriggered: if (controlPill.pillWidget === "workspace") controlPill.pillWidget = "clock"
        }

        Connections {
            target: VolumeService

            function onOsdRequested() {
                if (controlPill.pillWidget === "launcher" || controlPill.pillWidget === "lock") return

                controlPill.pillWidget = "volume"
                if (pillHoverHandler.hovered) volumeOsdTimer.stop()
                else volumeOsdTimer.restart()
            }
        }

        Connections {
            target: BrightnessService

            function onBrightnessChanged() {
                if (controlPill.pillWidget === "launcher" || controlPill.pillWidget === "lock") return

                controlPill.pillWidget = "brightness"
                if (pillHoverHandler.hovered) brightnessOsdTimer.stop()
                else brightnessOsdTimer.restart()
            }
        }

        Connections {
            target: WorkspaceService

            function onSwitched() {
                if (controlPill.pillWidget === "launcher" || controlPill.pillWidget === "lock") return

                controlPill.pillWidget = "workspace"
                if (pillHoverHandler.hovered) workspaceTimer.stop()
                else workspaceTimer.restart()
            }
        }

        // ── Possible Menus ────────────────────────────────────────────────────────
        Component {
            id: clockMenu;
            Item {
                id: clockcontrolPill

                property real horizontalPadding: 10
                property real verticalPadding: 4

                implicitWidth: clock.implicitWidth + horizontalPadding * 2
                implicitHeight: clock.implicitHeight + verticalPadding * 2

                Text {
                    id: clock
                    anchors.centerIn: parent
                    color: ActiveTheme.colors["FG"]
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
            id: volumeOsd
            Item {
                id: volumecontrolPill

                readonly property real padding: 10
                property real iconSize: 16

                implicitWidth:  volumeRow.implicitWidth  + padding * 2
                implicitHeight: Math.max(volumeRow.implicitHeight, iconSize) + padding * 2

                RowLayout {
                    id: volumeRow
                    anchors.centerIn: parent
                    spacing: 6

                    Image {
                        id: volumeIcon
                        Layout.alignment: Qt.AlignVCenter
                        source: VolumeService.muted
                                    ? Quickshell.shellDir + "/assets/icons/audio-volume-muted.svg"
                                    : Quickshell.shellDir + "/assets/icons/audio-volume-high.svg"
                        sourceSize.width:  volumecontrolPill.iconSize
                        sourceSize.height: volumecontrolPill.iconSize
                        width:  volumecontrolPill.iconSize
                        height: volumecontrolPill.iconSize
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    SlideBar {
                        id: slideBar
                        Layout.alignment: Qt.AlignVCenter
                        value: VolumeService.volume
                        minValue: 0
                        maxValue: 1
                        onSetValue: (v) => VolumeService.setVolume(v)
                    }
                }
            }
        }
        Component {
            id: brightnessOsd
            Item {
                id: brightnesscontrolPill

                readonly property real padding: 10
                property real iconSize: 16

                implicitWidth:  brightnessRow.implicitWidth  + padding * 2
                implicitHeight: Math.max(brightnessRow.implicitHeight, iconSize) + padding * 2

                RowLayout {
                    id: brightnessRow
                    anchors.centerIn: parent
                    spacing: 6

                    Image {
                        id: brightnessIcon
                        Layout.alignment: Qt.AlignVCenter
                        source: Quickshell.shellDir + "/assets/icons/brightness.svg"
                        sourceSize.width:  brightnesscontrolPill.iconSize
                        sourceSize.height: brightnesscontrolPill.iconSize
                        width:  brightnesscontrolPill.iconSize
                        height: brightnesscontrolPill.iconSize
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    SlideBar {
                        id: slideBar
                        Layout.alignment: Qt.AlignVCenter
                        value: BrightnessService.value
                        minValue: 0.02  // This matches window manager's keybind min limit
                        maxValue: 1
                        onSetValue: (v) => BrightnessService.setValue(v)
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

                function close() { controlPill.pillWidget = "clock" }

                // ── App entries ───────────────────────────────────────────────────────────
                function rebuildEntries() {
                    controlPill._entries = DesktopEntries.applications.values
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
                    controlPill._launchModes = [
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
                                const idx = controlPill._wallpaperFiles.indexOf(current)
                                const files = idx > 0
                                    ? [...controlPill._wallpaperFiles.slice(idx), ...controlPill._wallpaperFiles.slice(0, idx)]
                                    : controlPill._wallpaperFiles
                                
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
                                return controlPill._colorThemeFiles.map(entry => ({
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

                    controlPill._wallpaperFiles = []
                    wallpaperScanner.running = true

                    controlPill._colorThemeFiles = []
                    colorThemeScanner.running = true

                    LockService.refreshWallpaper()
                }

                // ── Content ───────────────────────────────────────────────────────────────
                Rectangle {
                    anchors.fill: parent
                    color: ActiveTheme.colors["BG"]
                    radius: controlPill.radius
                    clip: true

                    ColumnLayout {
                        id: contentColumn
                        anchors.centerIn: parent
                        spacing: 20

                        SearchBar {
                            id: searchBar
                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillWidth: true
                            entries: controlPill._entries
                            launchModes:   controlPill._launchModes
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
            id: workspaces

            Item {
                id: contentControlPill
                property real horizontalPadding: 8
                property real verticalPadding: 7

                readonly property int _radius: 15
                readonly property int _animDuration: 100

                implicitWidth: row.implicitWidth + horizontalPadding * 2
                implicitHeight: row.implicitHeight + verticalPadding * 2

                Row {
                    id: row
                    anchors.centerIn: parent
                    spacing: 10

                    Repeater {
                        model: WorkspaceService.states

                        Rectangle {
                            id: wsIndicator

                            required property var modelData

                            readonly property bool active:  modelData.active
                            readonly property bool exists:  modelData.exists

                            visible: modelData.visible

                            width: active ? contentControlPill._radius * 3 : contentControlPill._radius
                            height: contentControlPill._radius
                            radius: height / 2
                            color: WorkspaceService.colorFor(active, exists)

                            border {
                                width: 0
                                color: ActiveTheme.colors["FG"]
                            }

                            Behavior on color { ColorAnimation { duration: contentControlPill._animDuration } }

                            Behavior on width { NumberAnimation {
                                duration: contentControlPill._animDuration
                                easing.type: Easing.InOutCubic
                            }}

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true

                                onEntered: wsIndicator.border.width = 2
                                onExited: wsIndicator.border.width = 0
                                onClicked: WorkspaceService.activate(modelData.id)
                            }
                        }
                    }
                }
            }
        }
        Component {
            id: lockDecoy
            LockVisual {
                implicitWidth:  panwin.screen ? panwin.screen.width  : 0
                implicitHeight: panwin.screen ? panwin.screen.height : 0
                wallpaper: LockService.currentWallpaper   // shared source, see note below
            }
        }
        LockScreen { id: lockScreen }

        onPillWidgetChanged: {
            switch (pillWidget) {
                case "volume":      controlPill.content = volumeOsd;        break
                case "brightness":  controlPill.content = brightnessOsd;    break
                case "lock":        controlPill.content = lockDecoy;        break
                case "launcher":    controlPill.content = controlCenter;    break
                case "workspace":   controlPill.content = workspaces;       break
                default:            controlPill.content = clockMenu;        break
            }
        }
        Component.onCompleted: controlPill.content = clockMenu

        HoverHandler {
            id: pillHoverHandler
            cursorShape: Qt.PointingHandCursor

            onHoveredChanged: {
                switch (controlPill.pillWidget) {
                    case "volume":
                        if (hovered) volumeOsdTimer.stop()
                        else volumeOsdTimer.restart()
                        break
                    case "brightness":
                        if (hovered) brightnessOsdTimer.stop()
                        else brightnessOsdTimer.restart()
                        break
                    case "workspace":
                        if (hovered) workspaceTimer.stop()
                        else workspaceTimer.restart()
                        break
                    default:
                        break
                }
            }
        }

        // ── Morph handoff ────────────────────────────────────────────────────
        Connections {
            target: controlPill
            function onMorphFinished() {
                if (controlPill.pillWidget === "clock") controlPill.clockHeight = controlPill.height
                if (controlPill.pillWidget === "lock" && !lockScreen.isLocked) {
                    controlPill.square = true
                    lockScreen.lock()   // decoy is fully fullscreen now — safe to hand off
                }
            }
        }

        Connections {
            target: lockScreen
            function onReadyToUnlock() {
                controlPill.square = false
                lockScreen.unlock()      // decoy still fullscreen underneath — no flash
                controlPill.pillWidget = "clock"    // now shrink back down
            }
        }
    }

    function toggleLauncher(): void { controlPill.toggleLauncher() }
    function lockSession(): void { controlPill.lockSession() }
    function reset(): void { controlPill.reset() }
}
