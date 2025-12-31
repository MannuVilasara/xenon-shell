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
        text: "Background"
        font.family: Config.fontFamily
        font.pixelSize: 20
        font.bold: true
        color: colors.fg
    }

    // Wallpaper Directory
    SettingItem {
        label: "Wallpaper Directory"
        sublabel: "Path to wallpaper folder"
        icon: "󰸉"
        colors: context.colors

        TextField {
            Layout.preferredWidth: 350
            text: Config.wallpaperDirectory
            font.pixelSize: 13
            color: colors.fg
            background: null
            horizontalAlignment: TextInput.AlignRight
            
            onEditingFinished: {
                if (text !== "") Config.wallpaperDirectory = text
            }
        }
    }
}

