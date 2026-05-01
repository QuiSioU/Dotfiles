/* quickshell/themes/ThemeLoader.qml */


import QtQuick
import Quickshell
import Quickshell.Io
import ElyseanShell.Themes


QtObject {
    property var _file: FileView {
        path: Quickshell.env("HOME") + "/.config/elysean_themes/active_theme"
        onLoadedChanged: {
            if (!loaded) return

            ActiveTheme.ready = false

            const result = {}
            for (const line of text().split("\n")) {
                const trimmed = line.trim()
                if (!trimmed.startsWith("$")) continue

                const eq = trimmed.indexOf("=")
                if (eq === -1) continue

                const key = trimmed.slice(0, eq).trim().replace(/^\$/, "")  // Hyprland's $VAR format
                const val = trimmed.slice(eq + 1).trim()

                // input: RRGGBBAA || Quickshell expects: AARRGGBB
                const rgba = val.match(/^rgba\(([a-zA-Z0-9]{6})([a-zA-Z0-9]{2})\)$/)
                result[key] = rgba ? "#" + rgba[2] + rgba[1] : val

                console.log(JSON.stringify(key), "=", JSON.stringify(val))
            }

            ActiveTheme.color = result

            ActiveTheme.ready = true
        }
    }
}
