import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Core

PanelWindow {
    id: screenCorners

    property var context

    visible: !context.activeWindow.isFullscreen
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "quickshell:screenCorners"
    WlrLayershell.layer: WlrLayer.Overlay

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    property int barHeight: {
        switch (context.config.barSize) {
            case "compact": return 35;
            case "expanded": return 50;
            default: return 40;
        }
    }

    Behavior on barHeight {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutQuad
        }
    }

    RoundCorner {
        id: topLeft

        size: 25
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: (!context.config.floatingBar && context.config.barPosition === "top") ? barHeight : 0
        corner: RoundCorner.CornerEnum.TopLeft
        color: context.colors.bg
    }

    RoundCorner {
        id: topRight

        size: 25
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: (!context.config.floatingBar && context.config.barPosition === "top") ? barHeight : 0
        corner: RoundCorner.CornerEnum.TopRight
        color: context.colors.bg
    }

    RoundCorner {
        id: bottomLeft

        size: 25
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: (!context.config.floatingBar && context.config.barPosition === "bottom") ? barHeight : 0
        corner: RoundCorner.CornerEnum.BottomLeft
        color: context.colors.bg
    }

    RoundCorner {
        id: bottomRight

        size: 25
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: (!context.config.floatingBar && context.config.barPosition === "bottom") ? barHeight : 0
        corner: RoundCorner.CornerEnum.BottomRight
        color: context.colors.bg
    }

    mask: Region {
        item: null
    }

}
