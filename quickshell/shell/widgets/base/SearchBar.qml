/* quickshell/shell/widgets/base/SearchBar.qml */


import QtQuick
import QtQuick.Layouts
import ElysianShell.Themes

Rectangle {
    id: root
    Layout.preferredHeight: 50
    color: ActiveTheme.colors["BG_STRIPE"]
    radius: 12

    // ── Public API — inputs ──────────────────────────────────────────
    property var    entries:      []
    property var    launchModes:        []
    property string actionPrefix: "/"
    property bool   wrapNavigation: false

    // ── Public API — outputs ─────────────────────────────────────────
    property var filteredEntries: []
    property int currentIndex:    0
    readonly property var activeMode: {
        const text   = searchInput.text
        const prefix = root.actionPrefix
        if (!text.startsWith(prefix)) return null
        const rest = text.slice(prefix.length)
        return root.launchModes.find(
            m => rest === m.prefix + " " || rest.startsWith(m.prefix + " ")) ?? null
    }

    // ── Signals ───────────────────────────────────────────────────────
    signal closeRequested()
    signal navigated(int index)
    signal activated(var entry)

    // ── Public API — functions ────────────────────────────────────────
    function forceInputFocus() {
        searchInput.forceActiveFocus()
        root.currentIndex = 0
    }
    function clearInput() { searchInput.text = "" }
    function refresh()    { filterDebounce.restart() }

    // ── Filtering ─────────────────────────────────────────────────────
    Timer {
        id: filterDebounce
        interval: 50
        repeat: false
        onTriggered: root.filteredEntries = root.computeFilteredEntries()
    }

    function computeFilteredEntries() {
        const text   = searchInput.text
        const prefix = root.actionPrefix

        if (text.startsWith(prefix)) {
            const rest = text.slice(prefix.length).toLowerCase()
            const matchedMode = root.launchModes.find(
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

            return root.launchModes
                .filter(m => rest === "" || m.prefix.startsWith(rest) || m.label.toLowerCase().startsWith(rest))
                .map(m => ({
                    name:         m.label,
                    icon:         m.icon,
                    comment:      "Type " + prefix + m.prefix + " to browse",
                    isModeEntry:  true,
                    fallbackText: root.actionPrefix,
                    modePrefix:   prefix + m.prefix + " ",
                    stayOpen:     true,
                    action:       () => { searchInput.text = prefix + m.prefix + " " }
                }))
        }

        const q = text.toLowerCase()
        if (!q) return root.entries
        return root.entries.filter(e =>
            e.name.toLowerCase().includes(q) ||
            (e.comment ?? "").toLowerCase().includes(q))
    }

    // ── Navigation ────────────────────────────────────────────────────
    function _navigatePrev() {
        const count = root.filteredEntries.length
        if (count === 0) return
        const next = root.wrapNavigation
            ? (root.currentIndex - 1 + count) % count
            : Math.max(0, root.currentIndex - 1)
        root.currentIndex = next
        root.navigated(next)
    }
    function _navigateNext() {
        const count = root.filteredEntries.length
        if (count === 0) return
        const next = root.wrapNavigation
            ? (root.currentIndex + 1) % count
            : Math.min(count - 1, root.currentIndex + 1)
        root.currentIndex = next
        root.navigated(next)
    }
    function _activateCurrent() {
        const entry = root.filteredEntries[root.currentIndex]
        if (!entry) return
        root.activated(entry)
        if (!(entry.stayOpen ?? false)) root.closeRequested()
    }

    onEntriesChanged: refresh()
    Component.onCompleted: filteredEntries = computeFilteredEntries()

    // Shared key handling — both inputs forward here so Return/Up/Down/Escape
    // behave identically regardless of which one currently has focus.
    Item {
        id: keyHandler
        Keys.onReturnPressed: root._activateCurrent()
        Keys.onEscapePressed: root.closeRequested()

        Keys.onUpPressed: root._navigatePrev()
        Keys.onDownPressed: root._navigateNext()
        Keys.onLeftPressed: root._navigatePrev()
        Keys.onRightPressed: root._navigateNext()

        // Keys.onUpPressed: function(event) {
        //     if (!root.navHorizontal) {
        //         root._navigatePrev()
        //         event.accepted = true
        //     }
        // }
        // Keys.onDownPressed: function(event) {
        //     if (!root.navHorizontal) {
        //         root._navigateNext()
        //         event.accepted = true
        //     }
        // }
        // Keys.onLeftPressed: function(event) {
        //     if (root.navHorizontal) {
        //         root._navigatePrev()
        //         event.accepted = true
        //     }
        // }
        // Keys.onRightPressed: function(event) {
        //     if (root.navHorizontal) {
        //         root._navigateNext()
        //         event.accepted = true
        //     }
        // }
    }

    // ── Layout ────────────────────────────────────────────────────────
    Row {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 6
        visible: root.activeMode !== null

        Rectangle {
            visible: root.activeMode !== null
            height: 26
            width: chipLabel.implicitWidth + 16
            radius: 6
            color: ActiveTheme.colors["ACCENT_DIM"]
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: chipLabel
                anchors.centerIn: parent
                text: root.activeMode?.label ?? ""
                color: ActiveTheme.colors["FG"]
                font.pixelSize: 12
                font.weight: Font.Medium
            }
        }

        TextInput {
            id: modeInput
            width: parent.width - chipLabel.implicitWidth - 32
            anchors.verticalCenter: parent.verticalCenter
            color: ActiveTheme.colors["FG"]
            font.pixelSize: 16
            focus: root.activeMode !== null

            property string modePrefixText: root.activeMode
                ? (root.actionPrefix + root.activeMode.prefix + " ")
                : ""

            onModePrefixTextChanged: {
                if (root.activeMode !== null) {
                    const full = searchInput.text
                    text = full.startsWith(modePrefixText) ? full.slice(modePrefixText.length) : ""
                    forceActiveFocus()
                }
            }
            onTextChanged: {
                if (root.activeMode !== null)
                    searchInput.text = modePrefixText + text
            }

            Keys.priority: Keys.BeforeItem
            Keys.forwardTo: [keyHandler]
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
                color: ActiveTheme.colors["DARK3"]
                font.pixelSize: 16
                font.italic: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    TextInput {
        id: searchInput
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 16
        visible: root.activeMode === null
        focus:   root.activeMode === null
        color: searchInput.text.startsWith(root.actionPrefix)
                ? ActiveTheme.colors["ACCENT_DIM"] : ActiveTheme.colors["FG"]
        font.pixelSize: 16

        onTextChanged: {
            root.currentIndex = 0
            filterDebounce.restart()
            if (root.activeMode !== null)
                modeInput.forceActiveFocus()
        }

        Keys.priority: Keys.BeforeItem
        Keys.forwardTo: [keyHandler]
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

    Text {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 16
        visible: searchInput.text === "" && root.activeMode === null
        text: "Search apps  ·  type " + root.actionPrefix + " for commands"
        color: ActiveTheme.colors["DARK3"]
        font.pixelSize: 15
        font.italic: true
    }
}
