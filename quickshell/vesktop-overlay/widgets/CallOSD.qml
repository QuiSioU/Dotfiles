/* quickshell/shell/widgets/CallOSD.qml */


import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ElysianShell.Themes

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
        readonly property string imgCacheDir: Quickshell.cacheDir + "/pfp"

        // Where tiles get parented once created — swap Column for whatever layout you want later
        Column {
            id: userContainer
            spacing: 2
        }

        Component {
            id: userTileComponent

            Item {
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

                implicitWidth: tileRow.implicitWidth
                implicitHeight: tileRow.implicitHeight
                width: implicitWidth
                height: implicitHeight

                Row {
                    id: tileRow
                    anchors.centerIn: parent
                    spacing: 5

                    Rectangle {
                        readonly property int wPadding: 15
                        readonly property int hPadding: 10

                        width: nameRow.width + wPadding
                        height: nameRow.height + hPadding
                        color: tile.speak ? ActiveTheme.colors["BG"].replace("#", "#C0") : ActiveTheme.colors["BG"].replace("#", "#80")
                        radius: height / 2
                        anchors.verticalCenter: parent.verticalCenter

                        Row {
                            id: nameRow
                            anchors.centerIn: parent
                            spacing: 5

                            // Username
                            Text {
                                id: nameText
                                anchors.verticalCenter: parent.verticalCenter
                                text: tile.username
                                color: tile.speak ? ActiveTheme.colors["FG"] : ActiveTheme.colors["FG"].replace("#", "#80")
                                font.bold: true
                            }

                            // Microphone muted OSD
                            Image {
                                id: microOffImage
                                anchors.verticalCenter: parent.verticalCenter
                                width: 14; height: 14
                                source: Quickshell.shellDir + "/assets/icons/microphone-sensitivity-muted.svg"
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                visible: status === Image.Ready && !tile.micro
                                opacity: 0.5
                            }

                            // Audio deafen OSD
                            Image {
                                id: audioOffImage
                                anchors.verticalCenter: parent.verticalCenter
                                width: 14; height: 14
                                source: Quickshell.shellDir + "/assets/icons/audio-volume-muted_noalpha.svg"
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                visible: status === Image.Ready && !tile.audio
                                opacity: tile.speak ? 1.0 : 0.5
                            }
                        }
                    }

                    Rectangle {
                        readonly property int wPadding: 15
                        readonly property int hPadding: 5

                        width: videoScreenText.width + wPadding
                        height: videoScreenText.height + hPadding
                        color: "#ff0000"
                        radius: height / 2
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: tile.speak ? 1.0 : 0.5
                        visible: tile.video || tile.screen

                        Text {
                            id: videoScreenText
                            anchors.centerIn: parent
                            text: "LIVE"
                            color: ActiveTheme.colors["FG"]
                            font {
                                bold: true
                                pixelSize: 12
                            }
                        }
                    }
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

        // Handle avatar download if not cached
        function downloadAvatar(avatarURL, userID, username) {
            let imgExt = avatarURL.split("?")[0].split(".").pop()
            checkImgCached.imgSrc = avatarURL
            checkImgCached.imgDst = Quickshell.cacheDir + "/pfp/" + userID + "-" + username + "." + imgExt
            checkImgCached.running = true
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
                downloadAvatar(msg.avatarUrl, msg.userId, msg.username)
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
            connected: false

            parser: SplitParser {
                splitMarker: "\n"
                onRead: data => { root.handleData(data) }
            }

            onConnectedChanged: {
                if (connected) {
                    console.log("CallOSD: connected to bridge socket")
                } else {
                    console.log("CallOSD: lost connection to bridge socket, waiting for it to reappear")
                    sockWaiter.running = true
                }
            }

            onError: error => {
                console.warn("CallOSD: socket error:", error)
            }
        }

        Process {
            id: sockWaiter
            running: true
            command: [
                "bash", "-c",
                "until [ -S '" + sock.path + "' ]; do " +
                "inotifywait -qq -e create,moved_to '" + sock.path.substring(0, sock.path.lastIndexOf('/')) + "'; " +
                "done"
            ]

            onExited: (exitCode, exitStatus) => {
                console.log("CallOSD: bridge socket file appeared, connecting")
                sock.connected = true
            }
        }

        Process {
            id: checkImgCached
            running: false
            property string imgSrc: ""
            property string imgDst: ""
            command: [ "test", "-f", imgDst ]
            onExited: (exitCode) => {
                if (exitCode === 0) console.log("Profile picture already cached!")
                else {
                    console.log("Downloading profile picture from " + imgSrc + " to " + imgDst + "...")
                    imgDownload.imgSrc = imgSrc
                    imgDownload.imgDst = imgDst
                    imgDownload.running = true
                }
            }
        }

        Process {
            id: imgDownload
            running: false
            property string imgSrc: ""
            property string imgDst: ""
            command: [
                "sh", "-c",
                `mkdir -p "$(dirname '${imgDst}')" && curl -sL -o '${imgDst}' '${imgSrc}'`
            ]
        }
    }
}
