/* quickshell/shell/widgets/base/LockScreen.qml */


import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import ElysianShell.Themes
import ElysianShell.Services

Item {
    id: root
    property string passwordText: ""
    property string errorMessage: ""
    property bool errorVisible: false
    readonly property bool isLocked: sessionLock.locked

    signal readyToUnlock()

    function lock() {
        errorVisible = false
        errorMessage = ""
        sessionLock.locked = true
    }
    function unlock() { sessionLock.locked = false }

    PamContext {
        id: pam
        onPamMessage: if (responseRequired) respond(root.passwordText)
        onCompleted: (result) => {
            root.passwordText = ""
            if (result === PamResult.Success) {
                root.readyToUnlock()          // signal TopBar; don't unlock directly
            } else {
                root.errorMessage = "Incorrect password"
                root.errorVisible = true
            }
        }
        onError: (error) => console.log("PAM error:", error)
    }

    function tryUnlock() {
        if (passwordText.length === 0) return
        errorVisible = false
        if (!pam.start()) {
            errorMessage = "Couldn't start authentication"
            errorVisible = true
        }
    }

    WlSessionLock {
        id: sessionLock
        // no onLockedChanged→unlocked() here anymore — TopBar drives the transition

        WlSessionLockSurface {
            color: ActiveTheme.colors["BG"]

            LockVisual {
                anchors.fill: parent
                wallpaper: LockService.currentWallpaper   // same shared source as the decoy
            }

            Column {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 40 }
                spacing: 8

                Text { color: "#ff5f5f"; font.pixelSize: 14; text: root.errorMessage; visible: root.errorVisible }

                Rectangle {
                    anchors.left: parent.left; anchors.right: parent.right
                    height: 50; radius: 12
                    color: ActiveTheme.colors["BG_STRIPE"]

                    TextInput {
                        anchors.fill: parent
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
