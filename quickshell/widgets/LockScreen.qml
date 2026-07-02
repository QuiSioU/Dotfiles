/* quickshell/widgets/LockScreen.qml */


import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import ElysianShell.Themes


Item {
    id: root
    property string currentWallpaper: Quickshell.env("HOME") + "/.config/awww/default/Leshy.jpg"
    property string passwordText: ""
    property string errorMessage: ""
    property bool errorVisible: false
    
    signal unlocked()

    Process {
        id: awwwQueryProcess
        running: false
        command: [
            "bash", "-c", 
            "awww query | awk -F'image: ' '{print $2}'"
        ]
        
        stdout: SplitParser {
            onRead: function(line) {
                if (line.trim() !== "") {
                    root.currentWallpaper = "file://" + line.trim();
                }
            }
        }
    }

    function lock() {
        awwwQueryProcess.running = true;
        sessionLock.locked = true
    }
    function unlock() { sessionLock.locked = false }

    // --- PAM authentication ---
    PamContext {
        id: pam

        onPamMessage: {
            if (responseRequired) {
                respond(root.passwordText)
            }
        }

        onCompleted: (result) => {
            root.passwordText = ""
            if (result === PamResult.Success) {
                root.unlock()
            } else {
                root.errorMessage = "Incorrect password"
                root.errorVisible = true
            }
        }

        onError: (error) => {
            console.log("PAM error:", error)
        }
    }

    function tryUnlock() {
        if (root.passwordText.length === 0) return
        root.errorVisible = false
        if (!pam.start()) {
            root.errorMessage = "Couldn't start authentication"
            root.errorVisible = true
        }
    }

    WlSessionLock {
        id: sessionLock
        onLockedChanged: if (!locked) root.unlocked()

        WlSessionLockSurface {
            id: surface

            Rectangle {
                anchors.fill: parent
                color: "black"
                focus: true

                Image {
                    id: bgImage
                    anchors.fill: parent
                    source: root.currentWallpaper
                    fillMode: Image.PreserveAspectCrop
                    opacity: 0
                }

                MultiEffect {
                    anchors.fill: parent
                    source: bgImage
                    blurEnabled: true
                    blur: 1.0
                    blurMultiplier: 2.5
                    brightness: -0.15
                }

                Text {
                    id: clock
                    anchors.centerIn: parent
                    color: "white"
                    font.pixelSize: 64
                    font.bold: true
                    text: Qt.formatTime(new Date(), "hh:mm")

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: clock.text = Qt.formatTime(new Date(), "hh:mm")
                    }
                }

                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 40
                    spacing: 8

                    Text {
                        color: "#ff5f5f"
                        font.pixelSize: 14
                        text: root.errorMessage
                        visible: root.errorVisible
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 50
                        color: ActiveTheme.colors["BG_STRIPE"]
                        radius: 12

                        TextInput {
                            id: passwdInput
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: 16
                            color: ActiveTheme.colors["FG"]
                            font.pixelSize: 16
                            echoMode: TextInput.Password
                            focus: true
                            enabled: !pam.active
                            text: root.passwordText

                            onTextChanged: root.passwordText = text
                            onAccepted: root.tryUnlock()
                        }
                    }
                }
            }
        }
    }
}
