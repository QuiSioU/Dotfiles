// widgets/Launcher/Base/Launcher.qml

import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: panwin
    implicitWidth: 750
    implicitHeight: 500
    color: "transparent"
    focusable: true
    visible: false

    property var entries: []

    property var filteredEntries: {
        const q = searchInput.text.toLowerCase()
        if (!q) return entries
        return entries.filter(e =>
            e.name.toLowerCase().includes(q) ||
            (e.comment ?? "").toLowerCase().includes(q)
        )
    }

    HyprlandFocusGrab {
        windows: [ panwin ]
        active: panwin.visible
        onCleared: panwin.visible = false
    }

    onVisibleChanged: {
        if (visible) {
            searchInput.forceActiveFocus()
            appList.currentIndex = 0
        }
        else searchInput.text = ""
    }

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

                TextInput {
                    id: searchInput
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 16
                    focus: true
                    color: "#cdd6f4"
                    font.pixelSize: 16

                    onTextChanged: appList.currentIndex = 0

                    Keys.priority: Keys.BeforeItem
                    Keys.onEscapePressed: panwin.visible = false
                    Keys.onReturnPressed: {
                        if (filteredEntries.length > 0) {
                            filteredEntries[appList.currentIndex].action()
                            panwin.visible = false
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

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
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
                                        color: "#313244"
                                        radius: 4
                                        visible: iconImage.status !== Image.Ready

                                        Text {
                                            anchors.centerIn: parent
                                            text: (modelData.name ?? "").charAt(0).toUpperCase()
                                            color: "#cdd6f4"
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
                                        color: "#cdd6f4"
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
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    modelData.action()
                                    panwin.visible = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
