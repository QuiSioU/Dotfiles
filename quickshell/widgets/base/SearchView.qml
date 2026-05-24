/* quickshell/widgets/base/SearchView.qml */


import QtQuick
import QtQuick.Layouts
import ElyseanShell.Themes


ColumnLayout {
    id: root

    property var    entries:    []
    property var    modes:      []

    anchors.margins: 20
    spacing: 20

    // Public API
    function refresh()         { searchBar.refresh() }
    function forceInputFocus() { searchBar.forceInputFocus() }
    function clearInput()      { searchBar.clearInput() }

    // Signals
    signal closeRequested()

    // Handle action keys
    Keys.onEscapePressed: root.closeRequested()
    Keys.onReturnPressed:  {
        const entry = searchBar.filteredEntries[searchBar.currentIndex]
        if (entry) {
            entry.action()
            if (!entry.stayOpen) root.closeRequested()
        }
    }
    Keys.onUpPressed: {
        const next = Math.max(0, searchBar.currentIndex - 1)
        searchBar.currentIndex = next
        resultList.positionAt(next)
    }
    Keys.onDownPressed: {
        const next = Math.min(searchBar.filteredEntries.length - 1, searchBar.currentIndex + 1)
        searchBar.currentIndex = next
        resultList.positionAt(next)
    }

    onEntriesChanged: searchBar.refresh()

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 50
        color: ActiveTheme.color["BG_HIGHLIGHT"]
        radius: 12

        Item {
            id: searchBar

            anchors.fill: parent

            // ── Public API ────────────────────────────────────────────────────────────
            property string actionPrefix:    "/"

            // Outputs
            property var filteredEntries: []
            property int currentIndex:    0

            // Functions
            function forceInputFocus() {
                searchInput.forceActiveFocus()
                searchBar.currentIndex = 0
            }

            function clearInput() {
                searchInput.text = ""
            }

            // ── Filtering ─────────────────────────────────────────────────────────────
            Timer {
                id: filterDebounce
                interval: 50
                repeat: false
                onTriggered: searchBar.filteredEntries = searchBar.computeFilteredEntries()
            }

            function refresh() { filterDebounce.restart() }

            function computeFilteredEntries() {
                const text   = searchInput.text
                const prefix = searchBar.actionPrefix

                if (text.startsWith(prefix)) {
                    const rest = text.slice(prefix.length).toLowerCase()
                    const matchedMode = root.modes.find(
                        m => rest === "" || m.prefix.startsWith(rest) || rest.startsWith(m.prefix + " "))

                    if (matchedMode) {
                        const modePrefix = prefix + matchedMode.prefix + " "
                        if (text.startsWith(modePrefix)) {
                            const q = text.slice(modePrefix.length).toLowerCase()
                            const modeEntries = typeof matchedMode.entries === "function"
                                ? matchedMode.entries() : matchedMode.entries
                            if (!q) return modeEntries
                            return modeEntries.filter(e =>
                                e.name.toLowerCase().includes(q) ||
                                (e.comment ?? "").toLowerCase().includes(q))
                        }
                    }

                    return root.modes
                        .filter(m => rest === "" || m.prefix.startsWith(rest) || m.label.toLowerCase().startsWith(rest))
                        .map(m => ({
                            name:        m.label,
                            icon:        m.icon,
                            comment:     "Type " + prefix + m.prefix + " to browse",
                            isModeEntry: true,
                            fallbackText: searchBar.actionPrefix,
                            modePrefix:  prefix + m.prefix + " ",
                            stayOpen:    true,
                            action:      () => { searchInput.text = prefix + m.prefix + " " }
                        }))
                }

                const q = text.toLowerCase()
                if (!q) return root.entries
                return root.entries.filter(e =>
                    e.name.toLowerCase().includes(q) ||
                    (e.comment ?? "").toLowerCase().includes(q))
            }

            // ── Active mode ───────────────────────────────────────────────────────────
            readonly property var activeMode: {
                const text   = searchInput.text
                const prefix = searchBar.actionPrefix
                if (!text.startsWith(prefix)) return null
                const rest = text.slice(prefix.length)
                return root.modes.find(
                    m => rest === m.prefix + " " || rest.startsWith(m.prefix + " ")) ?? null
            }

            

            
            Component.onCompleted: searchBar.filteredEntries = computeFilteredEntries()

            // ── Layout ────────────────────────────────────────────────────────────────
            // Mode chip + sub-query input (visible when inside a mode)
            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 6
                visible: searchBar.activeMode !== null

                Rectangle {
                    visible: searchBar.activeMode !== null
                    height: 26
                    width: chipLabel.implicitWidth + 16
                    radius: 6
                    color: ActiveTheme.color["ACCENT_SURFACE"]
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: chipLabel
                        anchors.centerIn: parent
                        text: searchBar.activeMode?.label ?? ""
                        color: ActiveTheme.color["ACCENT"]
                        font.pixelSize: 12
                        font.weight: Font.Medium
                    }
                }

                TextInput {
                    id: modeInput
                    width: parent.width - chipLabel.implicitWidth - 32
                    anchors.verticalCenter: parent.verticalCenter
                    color: ActiveTheme.color["FG"]
                    font.pixelSize: 16
                    focus: searchBar.activeMode !== null

                    property string modesearchBar: searchBar.activeMode
                        ? (searchBar.actionPrefix + searchBar.activeMode.prefix + " ")
                        : ""

                    onModesearchBarChanged: {
                        if (searchBar.activeMode !== null) {
                            const full = searchInput.text
                            text = full.startsWith(modesearchBar) ? full.slice(modesearchBar.length) : ""
                            forceActiveFocus()
                        }
                    }

                    onTextChanged: {
                        if (searchBar.activeMode !== null)
                            searchInput.text = modesearchBar + text
                    }

                    Keys.priority: Keys.BeforeItem
                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Backspace && text === "") {
                            searchInput.text = searchBar.actionPrefix
                            event.accepted = true
                        }
                    }

                    Text {
                        visible: modeInput.text === ""
                        text: searchBar.activeMode?.placeholder
                            ?? ("Search " + (searchBar.activeMode?.label ?? "") + "...")
                        color: ActiveTheme.color["DARK5"]
                        font.pixelSize: 16
                        font.italic: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Plain search input
            TextInput {
                id: searchInput
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 16
                visible: searchBar.activeMode === null
                focus:   searchBar.activeMode === null
                color: searchInput.text.startsWith(searchBar.actionPrefix)
                        ? ActiveTheme.color["ACCENT"] : ActiveTheme.color["FG"]
                font.pixelSize: 16

                onTextChanged: {
                    searchBar.currentIndex = 0
                    filterDebounce.restart()
                    if (searchBar.activeMode !== null)
                        modeInput.forceActiveFocus()
                }

                Keys.priority: Keys.BeforeItem
                Keys.onTabPressed: {
                    if (searchBar.filteredEntries.length > 0) {
                        const entry = searchBar.filteredEntries[searchBar.currentIndex]
                        if (entry.isModeEntry) searchInput.text = entry.modePrefix
                    }
                }
                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Backspace && text === searchBar.actionPrefix) {
                        searchInput.text = ""
                        event.accepted = true
                    }
                }
            }

            // Placeholder hint
            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 16
                visible: searchInput.text === "" && searchBar.activeMode === null
                text: "Search apps  ·  type " + searchBar.actionPrefix + " for commands"
                color: ActiveTheme.color["DARK5"]
                font.pixelSize: 15
                font.italic: true
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "transparent"
        radius: 12
        clip: true

        Item {
            id: resultList

            anchors.fill: parent

            // ── Public API ────────────────────────────────────────────────────────────
            property var model:        searchBar.filteredEntries
            property int currentIndex: searchBar.currentIndex

            function positionAt(index) {
                listView.positionViewAtIndex(index, ListView.Contain)
            }

            // ── List ──────────────────────────────────────────────────────────────────
            ListView {
                id: listView
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8
                clip: true
                model: resultList.model
                currentIndex: resultList.currentIndex

                delegate: Item {
                    required property var modelData
                    required property int index
                    height: 52
                    width: ListView.view.width

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: index === resultList.currentIndex ? ActiveTheme.color["DARK3"]
                            : mouseArea.containsMouse    ? ActiveTheme.color["SURFACE_OVERLAY"]
                            : "transparent"

                        Rectangle {
                            visible: true
                            width: 3
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.margins: 6
                            color: modelData.isModeEntry ? ActiveTheme.color["ACCENT"] : ActiveTheme.color["URGENT"]
                            radius: 2
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            anchors.leftMargin: 14
                            spacing: 12

                            // Icon
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
                                    color: (modelData.isModeEntry ?? false)
                                                ? ActiveTheme.color["ACCENT_DIM"] : ActiveTheme.color["SURFACE"]
                                    radius: 4
                                    visible: iconImage.status !== Image.Ready

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.fallbackText ?? (modelData.name ?? "").charAt(0).toUpperCase()
                                        color: (modelData.isModeEntry ?? false)
                                                    ? ActiveTheme.color["ACCENT"] : ActiveTheme.color["FG"]
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                    }
                                }
                            }

                            // Name + comment
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: modelData.name ?? ""
                                    color: (modelData.isModeEntry ?? false)
                                            ? ActiveTheme.color["ACCENT"] : ActiveTheme.color["FG"]
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: modelData.comment ?? ""
                                    color: ActiveTheme.color["DARK5"]
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    visible: text !== ""
                                }
                            }

                            Text {
                                visible: modelData.isModeEntry ?? false
                                text: "→"
                                color: ActiveTheme.color["DARK3"]
                                font.pixelSize: 16
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                modelData.action()
                                if (!(modelData.stayOpen ?? false)) root.closeRequested()
                            }
                        }
                    }
                }
            }
        }
    }
}
