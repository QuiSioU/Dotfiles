/* quickshell/widgets/SystemMenu.qml */


import QtQuick
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import ElyseanShell.Services
import "base/orbit"

OrbitMenu {

    // ── Audio sink binding ─────────────────────────────────────────────────
    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

    // ── Entries ────────────────────────────────────────────────────────────

    OrbitEntry {
        name:     "WiFi"
        icon:     WiFiService.enabled ? "image://icon/network-wireless"
                                      : "image://icon/network-wireless-offline"
        comment:  WiFiService.enabled ? "On" : "Off"
        selected: WiFiService.enabled
        action:   function() { WiFiService.enabled = !WiFiService.enabled }
    }

    OrbitEntry {
        readonly property var adapter: Bluetooth.adapters.values[0] ?? null

        name:     "Bluetooth"
        icon:     (adapter?.enabled ?? false) ? Qt.resolvedUrl("../assets/icons/48x48/bluetooth-active.svg")
                                              : Qt.resolvedUrl("../assets/icons/48x48/bluetooth-disabled.svg")
        comment:  (adapter?.enabled ?? false) ? "On" : "Off"
        selected: adapter?.enabled ?? false
        action:   function() {
            if (adapter) adapter.enabled = !adapter.enabled
        }
    }

    OrbitEntry {
        readonly property bool muted: Pipewire.defaultAudioSink?.audio?.muted ?? false

        name:     "Sound"
        icon:     muted ? "image://icon/audio-volume-muted"
                        : "image://icon/audio-volume-high"
        comment:  muted ? "Muted" : "Unmuted"
        selected: !muted
        action:   function() {
            if (Pipewire.defaultAudioSink?.audio)
                Pipewire.defaultAudioSink.audio.muted = !muted
        }
    }
}
