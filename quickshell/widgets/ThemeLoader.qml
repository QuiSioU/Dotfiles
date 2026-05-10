/* quickshell/themes/ThemeLoader.qml */


import QtQuick
import Quickshell
import Quickshell.Io
import ElyseanShell.Themes


QtObject {
    property var _file: FileView {
        path: Quickshell.env("HOME") + "/.config/elysean_themes/active_theme"
        watchChanges: true

        onFileChanged: reload()

        onTextChanged: {
            if (!loaded) return

            ActiveTheme.ready = false

            const color = {}
            const token = {}
            for (const line of text().split("\n")) {
                const trimmed = line.trim()
                if (!trimmed.startsWith("$")) continue

                const eq = trimmed.indexOf("=")
                if (eq === -1) continue

                const key = trimmed.slice(0, eq).trim().replace(/^\$/, "")  // Hyprland's $VAR format
                const val = trimmed.slice(eq + 1).trim().replace(/#.*$/, "").trim()

                console.log(JSON.stringify(key), "=", JSON.stringify(val))

                if (key === "WALLPAPER") {
                    ActiveTheme.wallpaper = val.replace("~", Quickshell.env("HOME"))
                    continue
                }
                // input: RRGGBBAA || Quickshell expects: AARRGGBB
                const rgba = val.match(/^rgba\(([a-zA-Z0-9]{6})([a-zA-Z0-9]{2})\).*$/)

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
