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
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 64
        radius: 12
        color: colors.tile
        border.width: 1
        border.color: colors.border
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            
            Text {
                text: "󰸉"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 20
                color: colors.secondary
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                
                Text {
                    text: "Wallpaper Directory"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: colors.text
                }
                
                TextField {
                    Layout.fillWidth: true
                    text: Config.wallpaperDirectory
                    font.pixelSize: 13
                    color: colors.fg
                    background: null
                    // elide not supported
                    
                    onEditingFinished: {
                        if (text !== "") Config.wallpaperDirectory = text
                    }
                }
            }
        }
    }
}
