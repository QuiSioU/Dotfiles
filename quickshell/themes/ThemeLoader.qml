// themes/ThemeLoader.qml

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

    Loader {
        id: themeLoader
        source: ActiveTheme.themePath
    }

    Image {
        anchors.fill: parent
        source: themeLoader.item ? themeLoader.item.wallpaper : ""
        fillMode: Image.PreserveAspectCrop
    }
}

