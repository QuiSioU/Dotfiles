import QtQuick
import Quickshell
import Quickshell.Wayland
import "default"
import "user"

PanelWindow {
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true;
        bottom: true;
        left: true;
        right: true
    }

    // to change theme, swap "WitcherTokyoNight" → "MyTheme" (located in themes/user, imported above)
    WitcherTokyoNight {
        id: theme
    }

    Image {
        anchors.fill: parent
        source: theme.wallpaper
        fillMode: Image.PreserveAspectCrop
    }
}
