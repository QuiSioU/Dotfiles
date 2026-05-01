/* quickshell/widgets/Wallpaper.qml */


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

    Image {
        anchors.fill: parent
        source: Quickshell.shellDir + "/active_wallpaper"
        fillMode: Image.PreserveAspectCrop
    }
}
