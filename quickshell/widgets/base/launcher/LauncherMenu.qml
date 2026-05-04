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

    onEntriesChanged: filterDebounce.restart()

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

            // Active mode badge — shown when inside a specific mode
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                visible: launcher_panwin.activeMode !== null
                color: "#313244"
                radius: 8

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 6

                    Text {
                        text: launcher_panwin.activeMode?.icon ?? ""
                        font.family: "Material Symbols Rounded"
                        font.pixelSize: 14
                        color: "#89b4fa"
                        visible: false // flip to true if you use Material Icons font
                    }

                    Text {
                        text: (launcher_panwin.activeMode?.label ?? "") + " mode"
                        color: "#89b4fa"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "Esc to go back"
                        color: "#6c7086"
                        font.pixelSize: 11
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: "#181825"
                radius: 12

                TextInput {
                    id: searchInput
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 16
                    focus: true
                    color: "#cdd6f4"
                    font.pixelSize: 16

                    // Tint the "/" prefix in command mode
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
                    }

                    Keys.priority: Keys.BeforeItem
                    Keys.onEscapePressed: {
                        const prefix = launcher_panwin.actionPrefix
                        if (searchInput.text.length > prefix.length && searchInput.text.startsWith(prefix)) {
                            // If inside a mode with extra text, back up to mode root
                            const activeM = launcher_panwin.activeMode
                            if (activeM) {
                                searchInput.text = prefix + activeM.prefix + " "
                                return
                            }
                            // Back to showing mode list
                            searchInput.text = prefix
                        } else {
                            launcher_panwin.visible = false
                        }
                    }
                    Keys.onReturnPressed: {
                        if (filteredEntries.length > 0) {
                            const entry = filteredEntries[appList.currentIndex]
                            if (entry.isModeEntry) {
                                // Navigate into the mode
                                searchInput.text = entry.modePrefix
                            } else {
                                entry.action()
                                if (!entry.stayOpen)
                                    launcher_panwin.visible = false
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

                    // Tab completes the current mode
                    Keys.onTabPressed: {
                        if (filteredEntries.length > 0) {
                            const entry = filteredEntries[appList.currentIndex]
                            if (entry.isModeEntry) {
                                searchInput.text = entry.modePrefix
                            }
                        }
                    }
                }

                // Hint text overlay (shown when empty)
                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 16
                    visible: searchInput.text === ""
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
