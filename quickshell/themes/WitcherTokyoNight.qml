import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: wallpaperWindow
    
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Image {
        anchors.fill: parent
        source: "../assets/wallpapers/Witcher_wallpaper2.jpg"
        fillMode: Image.PreserveAspectCrop
    }
}
