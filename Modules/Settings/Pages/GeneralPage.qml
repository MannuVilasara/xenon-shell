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

    // Font Family Input
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 72
        radius: 12
        color: colors.surface
        border.width: 1
        border.color: colors.border
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16
            
            Rectangle {
                width: 40; height: 40
                radius: 10
                color: Qt.rgba(colors.accent.r, colors.accent.g, colors.accent.b, 0.1)
                
                Text {
                    anchors.centerIn: parent
                    text: "󰛖"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 20
                    color: colors.accent
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Text {
                    text: "Font Family"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    color: colors.muted
                }
                
                TextField {
                    Layout.fillWidth: true
                    text: Config.fontFamily
                    font.family: Config.fontFamily
                    font.pixelSize: 14
                    color: colors.fg
                    
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
        }
    }

    // Font Size Control
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 72
        radius: 12
        color: colors.surface
        border.width: 1
        border.color: colors.border
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16
            
            Rectangle {
                width: 40; height: 40
                radius: 10
                color: Qt.rgba(colors.accent.r, colors.accent.g, colors.accent.b, 0.1)
                
                Text {
                    anchors.centerIn: parent
                    text: "󰛂"
                    font.pixelSize: 20
                    font.family: "Symbols Nerd Font"
                    color: colors.accent
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Text {
                    text: "Font Size"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    color: colors.muted
                }
                
                Text {
                    text: Config.fontSize + "px"
                    font.pixelSize: 14
                    color: colors.fg
                    font.bold: true
                }
            }
            
            RowLayout {
                spacing: 12
                
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
}
