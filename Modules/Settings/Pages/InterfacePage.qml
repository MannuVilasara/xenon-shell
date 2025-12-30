import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Widgets
import qs.Services

ColumnLayout {
    spacing: 16
    property var context
    property var colors: context.colors

    Text {
        text: "Interface"
        font.family: Config.fontFamily
        font.pixelSize: 20
        font.bold: true
        color: colors.fg
    }

    ToggleButton {
        Layout.fillWidth: true
        label: "Disable Hover Effects"
        sublabel: "Reduce animations for performance"
        icon: "󰏇"
        active: Config.disableHover
        theme: colors
        onActiveChanged: {
             if (Config.disableHover !== active) Config.disableHover = active
        }
    }
}
