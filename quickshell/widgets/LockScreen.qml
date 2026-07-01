/* quickshell/widgets/LockScreen.qml */


import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ElysianShell.Themes


Item {
    id: root
    property string currentWallpaper: Quickshell.env("HOME") + "/.config/awww/default/Leshy.jpg"
    
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

    WlSessionLock {
        id: sessionLock

        // Detect when the lock state changes back to false to notify the shell loader
        onLockedChanged: if (!locked) root.unlocked()

        WlSessionLockSurface {
            id: surface

            Rectangle {
                anchors.fill: parent
                color: "black"
                focus: true

                // 1. The source image (keep opacity at 1.0, but dim it via color/overlay if needed)
                Image {
                    id: bgImage
                    anchors.fill: parent
                    source: root.currentWallpaper
                    fillMode: Image.PreserveAspectCrop
                    visible: false // Hide original so only the blurred effect shows
                }

                // 2. The Blur Effect
                MultiEffect {
                    anchors.fill: parent
                    source: bgImage
                    
                    blurEnabled: true
                    blur: 1.0              // Maximum blur amount (0.0 to 1.0)
                    blurMultiplier: 2.5    // Scales the blur radius/spread safely (Default is 1.0)
                    
                    brightness: -0.15      // Dimming for readability
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

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) {
                        root.unlock()
                        event.accepted = true
                    }
                }
            }
        }
    }
}
