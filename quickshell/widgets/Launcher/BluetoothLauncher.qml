import Quickshell.Io
import QtQuick
import "Base"

Launcher {
    id: root

    Process {
        id: headsetProc
        command: ["/bin/sh", Qt.resolvedUrl("../../scripts/bluetooth/headset.sh").toString().replace("file://", "")]
        running: false
    }

    Process {
        id: dualsenseProc
        command: ["/bin/sh", Qt.resolvedUrl("../../scripts/bluetooth/dualsense.sh").toString().replace("file://", "")]
        running: false
    }

    entries: [
        {
            name: "Headset",
            icon: "audio-headset",
            comment: "Toggle headset bluetooth connection",
            action: () => headsetProc.running = true
        },
        {
            name: "DualSense",
            icon: "input-gaming",
            comment: "Toggle DualSense bluetooth connection",
            action: () => dualsenseProc.running = true
        }
    ]
}
