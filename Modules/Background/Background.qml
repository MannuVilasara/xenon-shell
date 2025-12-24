import QtQuick
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win

        property var modelData

        screen: modelData
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        color: "black"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        Wallpaper {
            id: wallpaper

            anchors.fill: parent
        }

    }

}
