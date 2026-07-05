/* quickshell/widgets/base/ResultView.qml */


import QtQuick
import QtQuick.Layouts
import ElysianShell.Themes

Item {
    id: root

    // ── Public API ────────────────────────────────────────────────────
    property var    model:        []
    property int    currentIndex: 0
    property string mode:         "items"   // "items" | "carousel" (later)

    signal closeRequested()
    signal activated(var entry)

    function positionAt(index) {
        if (loader.item && loader.item.positionAt)
            loader.item.positionAt(index)
    }

    Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: {
            switch (root.mode) {
                // case "carousel": return carouselDisplay   // added later
                default: return itemsDisplay
            }
        }
        onLoaded: {
            item.model = root.model
            item.currentIndex = Qt.binding(() => root.currentIndex)
        }
    }

    Connections {
        target: root
        function onModelChanged() {
            if (loader.item) loader.item.model = root.model
        }
    }

    Component {
        id: itemsDisplay

        Item {
            id: itemsRoot
            property var model:        []
            property int currentIndex: 0

            function positionAt(index) {
                listView.positionViewAtIndex(index, ListView.Contain)
            }

            ListView {
                id: listView
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8
                clip: true
                model: itemsRoot.model
                currentIndex: itemsRoot.currentIndex

                delegate: Item {
                    required property var modelData
                    required property int index
                    height: 52
                    width: ListView.view.width

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: index === itemsRoot.currentIndex ? ActiveTheme.colors["DARK4"]
                             : mouseArea.containsMouse           ? "#0fffffff"
                             : "transparent"

                        Rectangle {
                            visible: modelData.isModeEntry ?? false
                            width: 3
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.margins: 6
                            color: ActiveTheme.colors["ACCENT_DIM"]
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
                                    source: modelData.icon ?? ""
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    visible: status === Image.Ready
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    color: (modelData.isModeEntry ?? false)
                                                ? ActiveTheme.colors["BG_TINTED"] : ActiveTheme.colors["BG_HIGHLIGHT"]
                                    radius: 4
                                    visible: iconImage.status !== Image.Ready

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.fallbackText ?? (modelData.name ?? "").charAt(0).toUpperCase()
                                        color: (modelData.isModeEntry ?? false)
                                                    ? ActiveTheme.colors["ACCENT_DIM"] : ActiveTheme.colors["FG"]
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: modelData.name ?? ""
                                    color: (modelData.isModeEntry ?? false)
                                            ? ActiveTheme.colors["ACCENT_DIM"] : ActiveTheme.colors["FG"]
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: modelData.comment ?? ""
                                    color: ActiveTheme.colors["FG_DARK"]
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    visible: text !== ""
                                }
                            }

                            Text {
                                visible: modelData.isModeEntry ?? false
                                text: "→"
                                color: ActiveTheme.colors["DARK4"]
                                font.pixelSize: 16
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                root.activated(modelData)
                                if (!(modelData.stayOpen ?? false))
                                    root.closeRequested()
                            }
                        }
                    }
                }
            }
        }
    }
}
