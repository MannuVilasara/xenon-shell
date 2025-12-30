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
        text: "Bar"
        font.family: Config.fontFamily
        font.pixelSize: 20
        font.bold: true
        color: colors.fg
    }

    ToggleButton {
        Layout.fillWidth: true
        label: "Floating Bar"
        sublabel: "Detach bar from screen edges"
        icon: "󰖲"
        active: Config.floatingBar
        theme: colors
        
        onActiveChanged: {
            if (Config.floatingBar !== active) Config.floatingBar = active
        }
    }
}
