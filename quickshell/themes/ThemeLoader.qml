/* quickshell/themes/ThemeLoader.qml */


import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ElyseanShell.Themes


PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true;
        bottom: true;
        left: true;
        right: true
    }

    // Set ELYSEAN_THEME_PATH to a path relative to themes/, e.g.:
    //   export ELYSEAN_THEME_PATH="user/PlatypusTokyoNight.conf"
    // If not set, it will default to "default/WitcherTokyoNight.conf"
    readonly property string activeTheme: {
        const env = Quickshell.env("ELYSEAN_THEME_PATH")
        return (env && env.length > 0) ? env : "default/WitcherTokyoNight.conf"
    }

    FileView {
        id: themeFile
        path: Quickshell.shellDir + "/themes/" + activeTheme
        onLoadedChanged: {
            if (!loaded) return

            console.log("Theme file path:", themeFile.path)

            const result = {}
            for (const line of text().split("\n")) {
                const trimmed = line.trim()
                if (!trimmed || trimmed.startsWith("#")) continue

                const eq = trimmed.indexOf("=")
                if (eq === -1) continue

                const key = trimmed.slice(0, eq).trim()
                const val = trimmed.slice(eq + 1).trim()
                result[key] = val

                console.log("Parsed key:", JSON.stringify(key), "val:", JSON.stringify(val))
            }

            // Write to singleton here, after parsing
            ActiveTheme.color_1  = "#" + (result["COLOR_1"] ?? "7dcfff")
            ActiveTheme.color_2  = "#" + (result["COLOR_2"] ?? "7aa2f7")
            ActiveTheme.color_3  = "#" + (result["COLOR_3"] ?? "bb9af7")
            ActiveTheme.color_4  = "#" + (result["COLOR_4"] ?? "9ece6a")
            ActiveTheme.color_5  = "#" + (result["COLOR_5"] ?? "ff9e64")
            ActiveTheme.color_6  = "#" + (result["COLOR_6"] ?? "1a3a5c")
            ActiveTheme.color_7  = "#" + (result["COLOR_7"] ?? "1f2335")

            const p = result["WALLPAPER_PATH"]
            ActiveTheme.wallpaper = p
                ? (Quickshell.shellDir + "/assets/wallpapers/" + p)
                : ""
        }
    }

    Image {
        anchors.fill: parent
        source: ActiveTheme.wallpaper
        fillMode: Image.PreserveAspectCrop
    }
}
