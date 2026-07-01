/* quickshell/widgets/LockScreen.qml */


import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ElysianShell.Themes


WlSessionLock {
    id: root
    property string currentWallpaper: Quickshell.env("HOME") + "/.config/awww/default/Leshy.jpg"
    
    signal unlocked()

    function lock() { root.locked = true }
    function unlock() { root.locked = false }

    // Detect when the lock state changes back to false to notify the shell loader
    onLockedChanged: if (!locked) root.unlocked()

    Process {
        id: swwwQueryProcess
        // Run via bash to support the pipe '|' operator
        command: [
            "bash", "-c", 
            "swww query | awk -F'image: ' '{print $2}'"
        ]
        
        stdout: SplitParser {
            onRead: function(line) {
                if (line.trim() !== "") {
                    root.currentWallpaper = "file://" + line.trim();
                }
            }
        }
    }

    WlSessionLockSurface {
        id: surface
        color: "black"

        Item {
            anchors.fill: parent
            focus: true

            Image {
                anchors.fill: parent
                source: root.currentWallpaper // Path to your wallpaper
                fillMode: Image.PreserveAspectCrop
                opacity: 0.5 // Control the dimming here safely inside the surface
            }

            Keys.onPressed: (event) => {
                // Pressing Escape triggers unlock (replace this with your actual authentication logic)
                if (event.key === Qt.Key_Escape) {
                    root.unlock()
                    event.accepted = true
                }
            }
        }
    }
}
