/* quickshell/shell/modules/Services/Volume/VolumeService.qml */


pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root

    // The sink itself, for anything that needs more than volume/muted
    readonly property var sink: Pipewire.defaultAudioSink

    // Live, reactive state — no manual sync needed, Pipewire keeps these current
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted:  sink?.audio?.muted  ?? false

    property bool _seen: false

    // Fired only on genuine external/user changes, never on first attach —
    // this is what ControlPill uses to decide whether to pop the OSD
    signal osdRequested()

    // Keeps the sink's audio node alive/tracked, same role it played in ControlPill
    PwObjectTracker { objects: root.sink ? [root.sink] : [] }

    Connections {
        target: root.sink?.audio ?? null

        function onVolumeChanged() {
            if (!root._seen) { root._seen = true; return }
            root.osdRequested()
        }

        function onMutedChanged() {
            if (!root._seen) return
            root.osdRequested()
        }
    }

    function setVolume(v: real): void {
        if (sink?.audio) sink.audio.volume = v
    }

    function toggleMute(): void {
        if (sink?.audio) sink.audio.muted = !sink.audio.muted
    }
}
