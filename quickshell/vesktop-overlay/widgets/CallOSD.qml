/* quickshell/shell/widgets/CallOSD.qml */


import QtQuick
import Quickshell.Io

Item {
    id: root

    property var channels: ([])     // 2key-level dictionary: [ChannelID][UserID] = UserInfo

    function handleData(data) {
        try {
            var status = JSON.parse(data)
            console.log(status.type)
        } catch (e) {
            console.error("Failed to parse data:", e)
        }
    }

    Socket {
        id: sock
        path: "/tmp/callstatusbridge.sock"
        connected: true

        parser: SplitParser {
            splitMarker: "\n"
            onRead: data => { root.handleData(data) }
        }
    }
}
