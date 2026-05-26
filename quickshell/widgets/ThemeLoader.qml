/* quickshell/themes/ThemeLoader.qml */


import QtQuick
import Quickshell
import Quickshell.Io
import ElyseanShell.Themes


QtObject {
    property var _file: FileView {
        path: Quickshell.env("HOME") + "/.config/elysean_themes/active_theme/hypr_quickshell.lua"
        watchChanges: true

        onFileChanged: reload()

        onTextChanged: {
            if (!loaded) return

            ActiveTheme.ready = false

            const color = {}
            const token = {}

            for (const line of text().split("\n")) {
                const trimmed = line.trim()

                // skip blank lines and comments
                if (!trimmed || trimmed.startsWith("--")) continue

                const match = trimmed.match(/^(\w+)\s*=\s*"(.+?)"/)
                if (!match) continue

                const key = match[1]
                const val = match[2]

                console.log(JSON.stringify(key), "=", JSON.stringify(val))

                // input: RRGGBBAA || Quickshell expects: AARRGGBB
                const rgba = val.match(/^#([a-fA-F0-9]{6})([a-fA-F0-9]{2})$/)
                if (rgba) {
                    color[key] = "#" + rgba[2] + rgba[1]
                    continue
                }

                token[key] = val
            }

            ActiveTheme.color = color
            ActiveTheme.token = token
            ActiveTheme.ready = true
        }
    }
}
