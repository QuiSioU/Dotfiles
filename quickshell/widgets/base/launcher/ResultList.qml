/* quickshell/widgets/base/launcher/ResultList.qml */


import QtQuick
import QtQuick.Layouts

Item {
    id: root

    // ── Public API ────────────────────────────────────────────────────────────
    property var model:        []
    property int currentIndex: 0

    signal closeRequested()
    signal activated(var entry)

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
        model: root.model
        currentIndex: root.currentIndex

        delegate: Item {
            required property var modelData
            required property int index
            height: 52
            width: ListView.view.width

            Rectangle {
                anchors.fill: parent
                radius: 8
                color: index === root.currentIndex ? "#45475a"
                     : mouseArea.containsMouse    ? "#313244"
                     : "transparent"

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
                            color: (modelData.isModeEntry ?? false) ? "#1e3a5f" : "#313244"
                            radius: 4
                            visible: iconImage.status !== Image.Ready

                            Text {
                                anchors.centerIn: parent
                                text: modelData.fallbackText ?? (modelData.name ?? "").charAt(0).toUpperCase()
                                color: (modelData.isModeEntry ?? false) ? "#89b4fa" : "#cdd6f4"
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
                        root.activated(modelData)
                        if (!(modelData.stayOpen ?? false))
                            root.closeRequested()
                    }
                }
            }
        }
    }
}
