/* quickshell/themes/ThemeLoader.qml */


import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true;
        bottom: true;
        left: true;
        right: true
    }

    // Set ELYSEAN_THEME_PATH to a path relative to themes/, e.g.:
    //   export ELYSEAN_THEME_PATH="user/PlatypusTokyoNight.qml"
    // If not set, it will default to "default/WitcherTokyoNight.qml"
    readonly property string activeTheme: {
        const env = Quickshell.env("ELYSEAN_THEME_PATH")
        return (env && env.length > 0) ? env : "default/WitcherTokyoNight.qml"
    }

    Loader {
        id: themeLoader
        source: Qt.resolvedUrl(activeTheme)
    }

    Image {
        anchors.fill: parent
        source: themeLoader.item ? themeLoader.item.wallpaper : ""
        fillMode: Image.PreserveAspectCrop
    }
}

