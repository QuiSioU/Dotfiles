/* quickshell/shell/widgets/CallOSD.qml */


import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: panwin

    // anchor to a corner/edge — adjust to taste
    anchors {
        top: true
        left: true
    }

    margins {
        top: 20
        left: 20
    }

    // size the window itself — you'll likely want this to grow/shrink
    // with content once CallOSD has real visuals; for now, fix it
    implicitWidth: 400
    implicitHeight: 300

    color: "transparent" // so only your Rectangle/tiles show, not a solid backdrop

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace:     "vesktop-overlay"
    exclusionMode:               ExclusionMode.Ignore

    mask: Region { item: null }

    Item {
        id: root

        // tiles[channelId][userId] = UserTile instance (the source of truth for "who's on screen")
        property var tiles: ({})

        // Where tiles get parented once created — swap Column for whatever layout you want later
        Column {
            id: userContainer
            spacing: 2
        }

        Component {
            id: userTileComponent
            Rectangle {
                id: tile

                property string userId: ""
                property string channelId: ""
                property string username: ""
                property string avatarUrl: ""
                property bool micro: false
                property bool audio: false
                property bool video: false
                property bool screen: false
                property bool speak: false

                width: 400
                height: 32
                color: "#ffffff"

                // Placeholder visual — replace later
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: tile.username+"[M:"+tile.micro+" A:"+ tile.audio+" V:"+tile.video+" SS:"+tile.screen+" S:"+tile.speak+"]"
                }
            }
        }

        // Called on "joined": creates the tile if it doesn't exist yet, returns it either way
        function getOrCreateTile(channelId, userId) {
            if (!root.tiles[channelId]) root.tiles[channelId] = {}

            var tile = root.tiles[channelId][userId]
            if (!tile) {
                tile = userTileComponent.createObject(userContainer, {
                    channelId: channelId,
                    userId: userId
                })
                root.tiles[channelId][userId] = tile
            }
            return tile
        }

        // Called on "left": destroys the tile and cleans up empty channel entries
        function removeTile(channelId, userId) {
            var channelTiles = root.tiles[channelId]
            if (!channelTiles) return

            var tile = channelTiles[userId]
            if (tile) {
                tile.destroy()
                delete channelTiles[userId]
            }
            if (Object.keys(channelTiles).length === 0) {
                delete root.tiles[channelId]
            }
        }

        // Called on micro/audio/video/screen/speak: finds the existing tile and flips one property
        function updateTileState(channelId, userId, key, value) {
            var channelTiles = root.tiles[channelId]
            var tile = channelTiles ? channelTiles[userId] : null
            if (tile) tile[key] = value
        }

        function handleData(data) {
            var msg
            try {
                msg = JSON.parse(data)
            } catch (e) {
                console.error("Failed to parse data:", e)
                return
            }

            switch (msg.type) {
            case "joined": {
                var tile = getOrCreateTile(msg.channelId, msg.userId)
                tile.username = msg.username
                tile.avatarUrl = msg.avatarUrl
                break
            }

            case "left":
                removeTile(msg.channelId, msg.userId)
                break

            case "micro":
            case "audio":
            case "video":
            case "screen":
            case "speak":
                updateTileState(msg.channelId, msg.userId, msg.type, msg.status)
                break

            default:
                console.warn("Unknown message type:", msg.type)
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
}
