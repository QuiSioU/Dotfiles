/* quickshell/widgets/Wallpaper.qml */


import QtQuick
import Quickshell
import Quickshell.Wayland
import ElyseanShell.Themes

PanelWindow {
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    anchors {
        top: true;
        bottom: true;
        left: true;
        right: true
    }
    
    visible: ActiveTheme.ready && ActiveTheme.wallpaper !== ""

    Image {
        anchors.fill: parent
        source: ActiveTheme.wallpaper
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: Screen.width
        sourceSize.height: Screen.height
        cache: false
    }
}
