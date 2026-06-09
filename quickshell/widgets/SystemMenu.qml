/* quickshell/widgets/SystemMenu.qml */


import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import ElysianShell.Services
import "base"

PanelWindow {
    id: root
    color: "transparent"
    visible: false
    focusable: true

    anchors {
        top: true;
        bottom: true;
        left: true;
        right: true
    }

    signal menuClosed()

    function openMenu(set_index, posX, posY) {
        if (visible) return
        visible = true
        orbitMenu.openMenu(set_index ?? 0, posX, posY)
    }

    function closeMenu() {
        if (!visible) return
        orbitMenu.closeMenu()
    }

    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // ── Audio sink binding ─────────────────────────────────────────────────
    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

    // ── Audio source binding ───────────────────────────────────────────────
    PwObjectTracker {
        objects: Pipewire.defaultAudioSource ? [Pipewire.defaultAudioSource] : []
    }

    // ── Processes ──────────────────────────────────────────────────────────
    Process {
        id: shutdownProcess
        command: ["systemctl", "poweroff"]
        running: false
    }

    Process {
        id: rebootProcess
        command: ["systemctl", "reboot"]
        running: false
    }

    Process {
        id: logoutProcess
        command: [
            "bash", "-c",
            "loginctl terminate-session $(loginctl session-status | head -1 | awk '{print $1}')"
        ]
        running: false
    }

    // ── Menu ───────────────────────────────────────────────────────────────
    OrbitMenu {
        id: orbitMenu
        onCloseRequested: {
            root.visible = false
            root.menuClosed()
        }

        // ── Entries ────────────────────────────────────────────────────────────
        sets: [
            QtObject {
                property list<QtObject> entries: [

                    // Switch to session bubbles
                    QtObject {
                        property string name:       "Session"
                        property string icon:       Qt.resolvedUrl("../assets/images/color-palette.svg")
                        property string comment:    "Switch to session options"
                        property bool selected:   true
                        property bool stateful:   false
                        property var leftAction:     () => orbitMenu.switchSet(1)
                    },
            
                    // Sound
                    QtObject {
                        readonly property bool  muted:  Pipewire.defaultAudioSink?.audio?.muted  ?? false
                        readonly property real  volume: Pipewire.defaultAudioSink?.audio?.volume ?? 0
                        readonly property int   pct:    Math.round(volume * 100)

                        property string name:     "Sound"
                        property string icon:     muted                 ?   Qt.resolvedUrl("../assets/icons/audio-volume-muted.svg")
                                : pct === 0             ?   Qt.resolvedUrl("../assets/icons/audio-volume-low.svg")
                                : pct < 60              ?   Qt.resolvedUrl("../assets/icons/audio-volume-medium.svg")
                                :                           Qt.resolvedUrl("../assets/icons/audio-volume-high.svg")
                        property string comment:  muted ? "Muted" : pct + "%"
                        property bool selected: !muted
                        property bool stateful: true
                        property var leftAction:   function() {
                            if (Pipewire.defaultAudioSink?.audio)
                                Pipewire.defaultAudioSink.audio.muted = !muted
                        }
                    },

                    // Bluetooth
                    QtObject {
                        readonly property var adapter: Bluetooth.adapters.values[0] ?? null

                        property string name:     "Bluetooth"
                        property string icon:     !(adapter?.enabled ?? false) ? Qt.resolvedUrl("../assets/icons/bluetooth-disabled.svg")
                            : BluetoothDeviceModel.connectedNames.length > 0 ? Qt.resolvedUrl("../assets/icons/bluetooth-paired.svg")
                            : Qt.resolvedUrl("../assets/icons/bluetooth-active.svg")
                        property string comment:  !(adapter?.enabled ?? false)                  ? "Off"
                            : BluetoothDeviceModel.connectedNames.length > 0    ? BluetoothDeviceModel.connectedNames.join("\n")
                            : "On"
                        property bool selected: adapter?.enabled ?? false
                        property bool stateful: true
                        property var leftAction:   function() {
                            if (adapter) adapter.enabled = !adapter.enabled
                        }
                    },

                    // Airplane Mode
                    QtObject {
                        property bool prev_network: true
                        property bool prev_bluetooth: true

                        property string name:     "Airplane Mode"
                        property string icon: !selected ?   Qt.resolvedUrl("../assets/icons/airplane-mode-disabled.svg")
                            :               Qt.resolvedUrl("../assets/icons/airplane-mode-active.svg")

                        property string comment:  selected ? "On" : "Off"
                        property bool selected: false
                        property bool stateful: true
                        property var leftAction:   function() {
                            if (!selected) {
                                prev_network      = NetworkService.enabled
                                prev_bluetooth = Bluetooth.adapters.values[0]?.enabled ?? false

                                NetworkService.enabled = false
                                if (Bluetooth.adapters.values[0])
                                    Bluetooth.adapters.values[0].enabled = false

                                selected = true
                            }
                            else {
                                NetworkService.enabled = prev_network
                                if (Bluetooth.adapters.values[0])
                                    Bluetooth.adapters.values[0].enabled = prev_bluetooth

                                selected = false
                            }
                        }
                    },

                    // Network
                    QtObject {
                        property string name:     "Network"
                        property string icon: NetworkService.connectionType === "ethernet" ?   Qt.resolvedUrl("../assets/icons/network-wired.svg")
                            : !NetworkService.enabled       ?   Qt.resolvedUrl("../assets/icons/network-wireless-offline.svg")
                            : NetworkService.strength === 0 ?   Qt.resolvedUrl("../assets/icons/network-wireless-acquiring.svg")
                            : NetworkService.strength >= 80 ?   Qt.resolvedUrl("../assets/icons/network-wireless-80.svg")
                            : NetworkService.strength >= 60 ?   Qt.resolvedUrl("../assets/icons/network-wireless-60.svg")
                            : NetworkService.strength >= 40 ?   Qt.resolvedUrl("../assets/icons/network-wireless-40.svg")
                            :                                   Qt.resolvedUrl("../assets/icons/network-wireless-20.svg")

                        property string comment:  NetworkService.connectionType === "ethernet" ?   "Wired"
                            : NetworkService.enabled            ?   NetworkService.ssid
                            :                                       "Off"
                        property bool selected: NetworkService.connectionType !== "none"
                        property bool stateful: true
                        property var leftAction:   function() {
                        if (NetworkService.connectionType !== "ethernet")
                            NetworkService.enabled = !NetworkService.enabled
                        }
                    },

                    // Notifications
                    QtObject {
                        property string name:       "Notifications"
                        property string icon:       (NotificationService.showNotifications)
                                        ? Qt.resolvedUrl("../assets/icons/notification-active.svg")
                                        : Qt.resolvedUrl("../assets/icons/notification-disabled.svg")
                        property string comment:  (NotificationService.showNotifications) ? "On" : "Off"
                        property bool selected: NotificationService.showNotifications
                        property bool stateful: true
                        property var leftAction:   function() {
                            NotificationService.showNotifications = !NotificationService.showNotifications
                        }
                    }
                ]
            },
            QtObject {
                property list<QtObject> entries: [

                    // Switch to system bubbles
                    QtObject {
                        property string name:       "System"
                        property string icon:       Qt.resolvedUrl("../assets/images/color-palette.svg")
                        property string comment:    "Switch to system options"
                        property bool selected:   true
                        property bool stateful:   false
                        property var leftAction:     () => orbitMenu.switchSet(0)
                    },

                    // Shutdown
                    QtObject {
                        property string name:       "Shutdown"
                        property string icon:       Qt.resolvedUrl("../assets/icons/system-shutdown.svg")
                        property string comment:    "Shutdown computer"
                        property bool selected:   true
                        property bool stateful:   false
                        property var leftAction:     () => shutdownProcess.running = true
                    },

                    // Reboot
                    QtObject {
                        property string name:       "Reboot"
                        property string icon:       Qt.resolvedUrl("../assets/icons/system-reboot.svg")
                        property string comment:    "Reboot computer"
                        property bool selected:   true
                        property bool stateful:   false
                        property var leftAction:     () => rebootProcess.running = true
                    },

                    // Logout
                    QtObject {
                        property string name:       "Logout"
                        property string icon:       Qt.resolvedUrl("../assets/icons/system-log-out.svg")
                        property string comment:    "Logout from current session"
                        property bool selected:   true
                        property bool stateful:   false
                        property var leftAction:     () => logoutProcess.running = true
                    }
                ]
            }
        ]
    }
}
