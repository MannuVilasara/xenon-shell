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
        text: "Services"
        font.family: Config.fontFamily
        font.pixelSize: 20
        font.bold: true
        color: colors.fg
    }

    ToggleButton {
        Layout.fillWidth: true
        label: "Debug Mode"
        sublabel: "Enable verbose logging"
        icon: "󰃤"
        active: Config.debug
        theme: colors
        onActiveChanged: {
            if (Config.debug !== active) Config.debug = active
        }
    }

    // OpenRGB Devices
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
                text: "󰌌"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 20
                color: colors.secondary
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                
                Text {
                    text: "OpenRGB Devices (Indices)"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: colors.text
                }
                
                TextField {
                    Layout.fillWidth: true
                    // Hacky check for array
                    text: (Config.openRgbDevices && Array.isArray(Config.openRgbDevices)) 
                          ? Config.openRgbDevices.join(", ") 
                          : (Config.openRgbDevices || "")
                    placeholderText: "e.g. 0, 1"
                    font.pixelSize: 13
                    color: colors.fg
                    background: null
                    
                    onEditingFinished: {
                        var parts = text.split(",").map(Number).filter(n => !isNaN(n));
                        if (parts.length > 0) Config.openRgbDevices = parts;
                    }
                }
            }
        }
    }
}
