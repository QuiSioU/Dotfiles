/* quickshell/widgets/base/launcher/LauncherMenu.qml */


import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: launcher_panwin
    implicitWidth: 750
    implicitHeight: 500
    color: "transparent"
    focusable: true
    visible: false

    property var entries: []

    // --- Mode system ---
    // Typing "/" switches to command mode. The text after "/" determines
    // which sub-mode is active (bluetooth, wallpaper, theme, ...).
    // Sub-modes are registered via the modes list below.
    property string actionPrefix: "/"

    // Each mode: { prefix, label, icon, entries: [] | fn, placeholder }
    // Modes with a function for `entries` will be called on activation.
    property var modes: []

    // Resolved entries shown in the list
    property var filteredEntries: []

    Timer {
        id: filterDebounce
        interval: 50
        repeat: false
        onTriggered: launcher_panwin.filteredEntries = launcher_panwin.computeFilteredEntries()
    }

    function refresh() { filterDebounce.restart() }

    function computeFilteredEntries() {
        const text = searchInput.text
        const prefix = launcher_panwin.actionPrefix
        
        // Command mode: text starts with "/"
        if (text.startsWith(prefix)) {
            const rest = text.slice(prefix.length).toLowerCase()

            // Find a matching mode (e.g. "/blue" matches "bluetooth")
            const matchedMode = launcher_panwin.modes.find(m => rest === "" || m.prefix.startsWith(rest) || rest.startsWith(m.prefix + " "))

            if (matchedMode) {
                // Inside a mode: filter that mode's entries
                const modePrefix = prefix + matchedMode.prefix + " "
                if (text.startsWith(modePrefix)) {
                    const q = text.slice(modePrefix.length).toLowerCase()
                    const modeEntries = typeof matchedMode.entries === "function"
                        ? matchedMode.entries()
                        : matchedMode.entries
                    if (!q) return modeEntries
                    return modeEntries.filter(e =>
                        e.name.toLowerCase().includes(q) ||
                        (e.comment ?? "").toLowerCase().includes(q)
                    )
                }
            }

            // Show available modes as entries (filtered by what's typed after "/")
            return launcher_panwin.modes
                .filter(m => rest === "" || m.prefix.startsWith(rest) || m.label.toLowerCase().startsWith(rest))
                .map(m => ({
                    name: m.label,
                    icon: m.icon,
                    comment: "Type /" + m.prefix + " to browse",
                    isModeEntry: true,
                    modePrefix: prefix + m.prefix + " ",
                    action: () => { searchInput.text = prefix + m.prefix + " " }
                }))
        }

        // Normal app mode
        const q = text.toLowerCase()
        if (!q) return entries
        return entries.filter(e =>
            e.name.toLowerCase().includes(q) ||
            (e.comment ?? "").toLowerCase().includes(q)
        )
    }

    // Which mode are we currently inside? (for placeholder / header text)
    readonly property var activeMode: {
        const text = searchInput.text
        const prefix = launcher_panwin.actionPrefix
        if (!text.startsWith(prefix)) return null
        const rest = text.slice(prefix.length)
        return launcher_panwin.modes.find(m => rest === m.prefix + " " || rest.startsWith(m.prefix + " ")) ?? null
    }

    HyprlandFocusGrab {
        windows: [ launcher_panwin ]
        active: launcher_panwin.visible
        onCleared: launcher_panwin.visible = false
    }

    onVisibleChanged: {
        if (visible) {
            searchInput.forceActiveFocus()
            appList.currentIndex = 0
        }
        else searchInput.text = ""
    }

    onEntriesChanged: refresh()

    Component.onCompleted: filteredEntries = computeFilteredEntries()

    Rectangle {
        id: root
        anchors.fill: parent
        color: "#1e1e2e"
        radius: 12
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: "#181825"
                radius: 12

                // Chip + input row (shown when inside a mode)
                Row {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 10
                    spacing: 6
                    visible: launcher_panwin.activeMode !== null

                    // Mode chip
                    Rectangle {
                        visible: launcher_panwin.activeMode !== null
                        height: 26
                        width: chipLabel.implicitWidth + 16
                        radius: 6
                        color: "#1e3a5f"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            id: chipLabel
                            anchors.centerIn: parent
                            text: launcher_panwin.activeMode?.label ?? ""
                            color: "#89b4fa"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                        }
                    }

                    TextInput {
                        id: modeInput
                        width: parent.width - chipLabel.implicitWidth - 32
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#cdd6f4"
                        font.pixelSize: 16
                        focus: launcher_panwin.activeMode !== null

                        // Keep modeInput text in sync with the sub-query portion
                        property string modeRoot: launcher_panwin.activeMode
                            ? (launcher_panwin.actionPrefix + launcher_panwin.activeMode.prefix + " ")
                            : ""

                        // When activated, seed with whatever's already typed after the mode prefix
                        onModeRootChanged: {
                            if (launcher_panwin.activeMode !== null) {
                                const full = searchInput.text
                                text = full.startsWith(modeRoot) ? full.slice(modeRoot.length) : ""
                                forceActiveFocus()
                            }
                        }

                        onTextChanged: {
                            if (launcher_panwin.activeMode !== null)
                                searchInput.text = modeRoot + text
                        }

                        Keys.priority: Keys.BeforeItem
                        Keys.onReturnPressed: searchInput.Keys.returnPressed()
                        Keys.onUpPressed:     searchInput.Keys.upPressed()
                        Keys.onDownPressed:   searchInput.Keys.downPressed()
                        Keys.onEscapePressed: launcher_panwin.visible = false
                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_Backspace && text === "") {
                                searchInput.text = launcher_panwin.actionPrefix
                                event.accepted = true
                            }
                        }

                        Text {
                            visible: modeInput.text === ""
                            text: launcher_panwin.activeMode?.placeholder ?? ("Search " + (launcher_panwin.activeMode?.label ?? "") + "...")
                            color: "#45475a"
                            font.pixelSize: 16
                            font.italic: true
                            anchors.verticalCenter: parent.verticalCenter
                            // no left anchor needed — sits at modeInput's own origin
                        }
                    }
                }

                // Original TextInput — hidden when a mode chip is shown
                TextInput {
                    id: searchInput
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 16
                    visible: launcher_panwin.activeMode === null
                    focus: launcher_panwin.activeMode === null
                    color: "#cdd6f4"
                    font.pixelSize: 16

                    Text {
                        visible: searchInput.text.startsWith(launcher_panwin.actionPrefix)
                        text: launcher_panwin.actionPrefix
                        color: "#89b4fa"
                        font.pixelSize: 16
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    onTextChanged: {
                        appList.currentIndex = 0
                        filterDebounce.restart()
                        // If a mode just became active, hand focus to modeInput
                        if (launcher_panwin.activeMode !== null)
                            modeInput.forceActiveFocus()
                    }

                    Keys.priority: Keys.BeforeItem
                    Keys.onEscapePressed: launcher_panwin.visible = false
                    Keys.onReturnPressed: {
                        if (filteredEntries.length > 0) {
                            const entry = filteredEntries[appList.currentIndex]
                            if (entry.isModeEntry) {
                                searchInput.text = entry.modePrefix
                            } else {
                                entry.action()
                                if (!entry.stayOpen) launcher_panwin.visible = false
                            }
                        }
                    }
                    Keys.onUpPressed: {
                        appList.currentIndex = Math.max(0, appList.currentIndex - 1)
                        appList.positionViewAtIndex(appList.currentIndex, ListView.Contain)
                    }
                    Keys.onDownPressed: {
                        appList.currentIndex = Math.min(filteredEntries.length - 1, appList.currentIndex + 1)
                        appList.positionViewAtIndex(appList.currentIndex, ListView.Contain)
                    }
                    Keys.onTabPressed: {
                        if (filteredEntries.length > 0) {
                            const entry = filteredEntries[appList.currentIndex]
                            if (entry.isModeEntry) searchInput.text = entry.modePrefix
                        }
                    }
                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Backspace && text === launcher_panwin.actionPrefix) {
                            searchInput.text = ""
                            event.accepted = true
                        }
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 16
                    visible: searchInput.text === "" && launcher_panwin.activeMode === null
                    text: "Search apps  ·  type " + launcher_panwin.actionPrefix + " for commands"
                    color: "#45475a"
                    font.pixelSize: 15
                    font.italic: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#181825"
                radius: 12
                clip: true

                ListView {
                    id: appList
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8
                    clip: true
                    model: filteredEntries
                    currentIndex: 0

                    delegate: Item {
                        required property var modelData
                        required property int index
                        height: 52
                        width: ListView.view.width

                        Rectangle {
                            anchors.fill: parent
                            color: index === appList.currentIndex ? "#45475a"
                                : mouseArea.containsMouse ? "#313244"
                                : "transparent"
                            radius: 8

                            // Mode entries get a slightly different left accent
                            Rectangle {
                                visible: modelData.isModeEntry ?? false
                                width: 3
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.margins: 6
                                color: "#89b4fa"
                                radius: 2
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                anchors.leftMargin: (modelData.isModeEntry ?? false) ? 14 : 8
                                spacing: 12

                                Item {
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32

                                    Image {
                                        id: iconImage
                                        anchors.fill: parent
                                        source: modelData.icon ? "image://icon/" + modelData.icon : ""
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                        visible: status === Image.Ready
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        color: (modelData.isModeEntry ?? false) ? "#1e3a5f" : "#313244"
                                        radius: 4
                                        visible: iconImage.status !== Image.Ready

                                        Text {
                                            anchors.centerIn: parent
                                            text: (modelData.isModeEntry ?? false)
                                                ? launcher_panwin.actionPrefix
                                                : (modelData.name ?? "").charAt(0).toUpperCase()
                                            color: (modelData.isModeEntry ?? false) ? "#89b4fa" : "#cdd6f4"
                                            font.pixelSize: 14
                                            font.weight: Font.Medium
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: modelData.name
                                        color: (modelData.isModeEntry ?? false) ? "#89b4fa" : "#cdd6f4"
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: modelData.comment ?? ""
                                        color: "#6c7086"
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                        visible: text !== ""
                                    }
                                }

                                // Arrow hint for mode entries
                                Text {
                                    visible: modelData.isModeEntry ?? false
                                    text: "→"
                                    color: "#585b70"
                                    font.pixelSize: 16
                                }
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    if (modelData.isModeEntry ?? false) {
                                        searchInput.text = modelData.modePrefix
                                    } else {
                                        modelData.action()
                                        if (!(modelData.stayOpen ?? false))
                                            launcher_panwin.visible = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
