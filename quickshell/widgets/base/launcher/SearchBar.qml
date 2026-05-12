/* quickshell/widgets/base/launcher/SearchBar.qml */


import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    radius: 50
    color: "#181825"

    // ── Public API ────────────────────────────────────────────────────────────
    property var    entries:         []
    property var    modes:           []
    property string actionPrefix:    "/"

    // Outputs
    property var filteredEntries: []
    property int currentIndex:    0

    // Signals
    signal closeRequested()
    signal navigated(int index)
    signal activated()

    // Functions
    function forceInputFocus() {
        searchInput.forceActiveFocus()
        root.currentIndex = 0
    }

    function clearInput() {
        searchInput.text = ""
    }

    // ── Filtering ─────────────────────────────────────────────────────────────
    Timer {
        id: filterDebounce
        interval: 50
        repeat: false
        onTriggered: root.filteredEntries = root.computeFilteredEntries()
    }

    function refresh() { filterDebounce.restart() }

    function computeFilteredEntries() {
        const text   = searchInput.text
        const prefix = root.actionPrefix

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
                    modePrefix:  prefix + m.prefix + " ",
                    stayOpen:    true,
                    action:      () => { searchInput.text = prefix + m.prefix + " " }
                }))
        }

        const q = text.toLowerCase()
        if (!q) return entries
        return entries.filter(e =>
            e.name.toLowerCase().includes(q) ||
            (e.comment ?? "").toLowerCase().includes(q))
    }

    // ── Active mode ───────────────────────────────────────────────────────────
    readonly property var activeMode: {
        const text   = searchInput.text
        const prefix = root.actionPrefix
        if (!text.startsWith(prefix)) return null
        const rest = text.slice(prefix.length)
        return root.modes.find(
            m => rest === m.prefix + " " || rest.startsWith(m.prefix + " ")) ?? null
    }

    // ── Navigation helpers ────────────────────────────────────────────────────
    function _navigateUp() {
        const next = Math.max(0, root.currentIndex - 1)
        root.currentIndex = next
        root.navigated(next)
    }

    function _navigateDown() {
        const next = Math.min(root.filteredEntries.length - 1, root.currentIndex + 1)
        root.currentIndex = next
        root.navigated(next)
    }

    onEntriesChanged: refresh()
    Component.onCompleted: filteredEntries = computeFilteredEntries()

    // ── Layout ────────────────────────────────────────────────────────────────
    // Mode chip + sub-query input (visible when inside a mode)
    Row {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 6
        visible: root.activeMode !== null

        Rectangle {
            visible: root.activeMode !== null
            height: 26
            width: chipLabel.implicitWidth + 16
            radius: 50
            color: "#1e3a5f"
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: chipLabel
                anchors.centerIn: parent
                text: root.activeMode?.label ?? ""
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
            focus: root.activeMode !== null

            property string modeRoot: root.activeMode
                ? (root.actionPrefix + root.activeMode.prefix + " ")
                : ""

            onModeRootChanged: {
                if (root.activeMode !== null) {
                    const full = searchInput.text
                    text = full.startsWith(modeRoot) ? full.slice(modeRoot.length) : ""
                    forceActiveFocus()
                }
            }

            onTextChanged: {
                if (root.activeMode !== null)
                    searchInput.text = modeRoot + text
            }

            Keys.priority: Keys.BeforeItem
            Keys.onReturnPressed:  root.activated()
            Keys.onUpPressed:      root._navigateUp()
            Keys.onDownPressed:    root._navigateDown()
            Keys.onEscapePressed:  root.closeRequested()
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Backspace && text === "") {
                    searchInput.text = root.actionPrefix
                    event.accepted = true
                }
            }

            Text {
                visible: modeInput.text === ""
                text: root.activeMode?.placeholder
                    ?? ("Search " + (root.activeMode?.label ?? "") + "...")
                color: "#45475a"
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
        anchors.margins: 14
        visible: root.activeMode === null
        focus:   root.activeMode === null
        color: "#cdd6f4"
        font.pixelSize: 16

        Text {
            visible: searchInput.text.startsWith(root.actionPrefix)
            text: root.actionPrefix
            color: "#89b4fa"
            font.pixelSize: 16
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        onTextChanged: {
            root.currentIndex = 0
            filterDebounce.restart()
            if (root.activeMode !== null)
                modeInput.forceActiveFocus()
        }

        Keys.priority: Keys.BeforeItem
        Keys.onEscapePressed: root.closeRequested()
        Keys.onReturnPressed: root.activated()
        Keys.onUpPressed:     root._navigateUp()
        Keys.onDownPressed:   root._navigateDown()
        Keys.onTabPressed: {
            if (filteredEntries.length > 0) {
                const entry = filteredEntries[root.currentIndex]
                if (entry.isModeEntry) searchInput.text = entry.modePrefix
            }
        }
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Backspace && text === root.actionPrefix) {
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
        anchors.margins: 14
        visible: searchInput.text === "" && root.activeMode === null
        text: "Search apps  ·  type " + root.actionPrefix + " for commands"
        color: "#45475a"
        font.pixelSize: 15
        font.italic: true
    }
}
