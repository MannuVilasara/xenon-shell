import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Widgets
import qs.Services

ColumnLayout {
    spacing: 16
    property var context // Injected context

    property var colors: context.colors

    Text {
        text: "General"
        font.family: Config.fontFamily
        font.pixelSize: 20
        font.bold: true
        color: colors.fg
    }

    ToggleButton {
        Layout.fillWidth: true
        label: "Lock Screen Blur"
        sublabel: "Enable blur effect on lock screen"
        icon: ">"
        active: !Config.disableLockBlur
        theme: colors
        onActiveChanged: {
            if (active !== !Config.disableLockBlur) {
                Config.disableLockBlur = !active
            }
        }
    }

    // Font Family Input
    SettingItem {
        label: "Font Family"
        sublabel: "Global font family"
        icon: "󰛖"
        colors: context.colors

        TextField {
            Layout.preferredWidth: 350
            text: Config.fontFamily
            font.family: Config.fontFamily
            font.pixelSize: 14
            color: colors.fg
            horizontalAlignment: TextInput.AlignRight
            
            background: Rectangle {
                color: parent.activeFocus ? Qt.rgba(0,0,0,0.2) : "transparent"
                radius: 6
                border.width: parent.activeFocus ? 1 : 0
                border.color: colors.accent
            }
            
            onEditingFinished: {
                if (text !== "") Config.fontFamily = text
            }
        }
    }

    // Font Size Control
    SettingItem {
        label: "Font Size"
        sublabel: "Global font size"
        icon: "󰛂"
        colors: context.colors

        RowLayout {
            spacing: 12
            
            Text {
                text: Config.fontSize + "px"
                font.pixelSize: 14
                color: colors.fg
                font.bold: true
            }

            component Spincircle : Rectangle {
                property string symbol
                signal clicked()
                
                width: 32; height: 32
                radius: 16
                color: hover.containsMouse ? colors.tile : "transparent"
                border.width: 1
                border.color: colors.border
                
                Text {
                    anchors.centerIn: parent
                    text: symbol
                    color: colors.fg
                    font.pixelSize: 16
                }
                
                TapHandler {
                    onTapped: clicked()
                    cursorShape: Qt.PointingHandCursor
                }
                
                HoverHandler {
                    id: hover
                    cursorShape: Qt.PointingHandCursor
                }
            }
            
            Spincircle {
                symbol: "–"
                onClicked: Config.fontSize = Math.max(10, Config.fontSize - 1)
            }
            
            Spincircle {
                symbol: "+"
                onClicked: Config.fontSize = Math.min(24, Config.fontSize + 1)
            }
        }
    }
}
