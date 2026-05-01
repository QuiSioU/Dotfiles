/* quickshell/themes/ThemeLoader.qml */


import QtQuick
import Quickshell
import Quickshell.Io
import ElyseanShell.Themes


QtObject {
    // Set ELYSEAN_THEME_PATH to a path relative to themes/, e.g.:
    //   export ELYSEAN_THEME_PATH="user/PlatypusTokyoNight.conf"
    // If not set, it will default to "default/WitcherTokyoNight.conf"
    readonly property string activeTheme: {
        const env = Quickshell.env("ELYSEAN_THEME_PATH")
        return (env && env.length > 0) ? env : "default/WitcherTokyoNight.conf"
    }

    function expand_home(path) {
        if (path.startsWith("~/"))
            return Quickshell.env("HOME") + path.slice(1)
        return path
    }

    property var _file: FileView {
        path: Quickshell.shellDir + "/themes/" + activeTheme
        onLoadedChanged: {
            if (!loaded) return

            ActiveTheme.ready = false

            const result = {}
            for (const line of text().split("\n")) {
                const trimmed = line.trim()
                if (!trimmed || trimmed.startsWith("#")) continue

                const eq = trimmed.indexOf("=")
                if (eq === -1) continue

                const key = trimmed.slice(0, eq).trim()
                const val = trimmed.slice(eq + 1).trim()

                if (key === "WALLPAPER_PATH") {
                    const p = expand_home(val)
                    ActiveTheme.wallpaper = p ? p : ""
                } else {
                    // input: RRGGBBAA || Quickshell expects: AARRGGBB
                    const rgba = val.match(/^rgba\(([a-zA-Z0-9]{6})([a-zA-Z0-9]{2})\)$/)
                    result[key] = rgba ? "#" + rgba[2] + rgba[1] : val
                }

                console.log(JSON.stringify(key), "=", JSON.stringify(val))
            }

            ActiveTheme.color = result

            ActiveTheme.ready = true
        }
    }
}
