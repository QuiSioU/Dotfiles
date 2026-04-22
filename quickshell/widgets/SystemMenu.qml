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

    // ── Audio source binding ───────────────────────────────────────────────
    PwObjectTracker {
        objects: Pipewire.defaultAudioSource ? [Pipewire.defaultAudioSource] : []
    }

    // ── Entries ────────────────────────────────────────────────────────────

    OrbitEntry {
        name:     "WiFi"
        icon: !WiFiService.enabled          ? Qt.resolvedUrl("../assets/icons/network-wireless-offline.svg")
            : WiFiService.strength === 0    ? Qt.resolvedUrl("../assets/icons/network-wireless-acquiring.svg")
            : WiFiService.strength >= 80    ? Qt.resolvedUrl("../assets/icons/network-wireless-80.svg")
            : WiFiService.strength >= 60    ? Qt.resolvedUrl("../assets/icons/network-wireless-60.svg")
            : WiFiService.strength >= 40    ? Qt.resolvedUrl("../assets/icons/network-wireless-40.svg")
            :                                 Qt.resolvedUrl("../assets/icons/network-wireless-20.svg")
        
        comment:  WiFiService.enabled ? "On" : "Off"
        selected: WiFiService.enabled
        stateful: true
        action:   function() { WiFiService.enabled = !WiFiService.enabled }
    }

    OrbitEntry {
        readonly property var adapter: Bluetooth.adapters.values[0] ?? null

        name:     "Bluetooth"
        icon:     (adapter?.enabled ?? false) ? Qt.resolvedUrl("../assets/icons/bluetooth-active.svg")
                                              : Qt.resolvedUrl("../assets/icons/bluetooth-disabled.svg")
        comment:  (adapter?.enabled ?? false) ? "On" : "Off"
        selected: adapter?.enabled ?? false
        stateful: true
        action:   function() {
            if (adapter) adapter.enabled = !adapter.enabled
        }
    }

    OrbitEntry {
        readonly property bool  muted:  Pipewire.defaultAudioSink?.audio?.muted  ?? false
        readonly property real  volume: Pipewire.defaultAudioSink?.audio?.volume ?? 0
        readonly property int   pct:    Math.round(volume * 100)

        name:     "Sound"
        icon:     muted                 ?   Qt.resolvedUrl("../assets/icons/audio-volume-muted.svg")
                : pct === 0             ?   Qt.resolvedUrl("../assets/icons/audio-volume-low.svg")
                : pct < 60              ?   Qt.resolvedUrl("../assets/icons/audio-volume-medium.svg")
                :                           Qt.resolvedUrl("../assets/icons/audio-volume-high.svg")
        comment:  muted ? "Muted" : pct + "%"
        selected: !muted
        stateful: true
        action:   function() {
            if (Pipewire.defaultAudioSink?.audio)
                Pipewire.defaultAudioSink.audio.muted = !muted
        }
    }

    OrbitEntry {
        readonly property bool muted: Pipewire.defaultAudioSource?.audio?.muted ?? false

        name:     "Microphone"
        icon:     muted ? "image://icon/microphone-sensitivity-muted"
                        : "image://icon/microphone-sensitivity-high"
        comment:  muted ? "Muted" : "Unmuted"
        selected: !muted
        stateful: true
        action:   function() {
            if (Pipewire.defaultAudioSource?.audio)
                Pipewire.defaultAudioSource.audio.muted = !muted
        }
    }
}
