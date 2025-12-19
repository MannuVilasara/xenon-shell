import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import qs.Core
import qs.Services
import "../../../../Services" as Services

ColumnLayout {
    id: root
    
    required property var theme
    
    spacing: 16
    
    // --- Album Art / Vinyl ---
    Item {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 240 // Increased for visualizer space
        Layout.preferredHeight: 240
        
        // Control Cava Service
        Connections {
            target: Services.CavaService
            function onValuesChanged() { visualizerRepeater.requestPaint() } // Optimization if needed
        }
        
        // Activate Cava only when this view is likely visible/playing
        Binding {
            target: Services.CavaService
            property: "running"
            value: MprisService.isPlaying && root.visible
        }

        // Visualizer Bars (Behind Art)
        Repeater {
            id: visualizerRepeater
            model: 32 // Matches CavaService barsCount
            
            Rectangle {
                id: bar
                property var val: Services.CavaService.values[index] || 0
                
                anchors.centerIn: parent
                // Visualizer bar dimensions
                width: 6
                // Base height needs to cover the 200px diameter hole (100px radius)
                // We center it. So to poke out of 100px radius, half-height must be > 100.
                // Height = 200 + (val * 100). Half-height = 100 + (val * 50).
                // This means it starts exactly at the edge of the circle.
                height: 200 + (val * 150) 
                
                color: theme.purple
                opacity: 0.8 // Increased opacity
                radius: 3
                
                // Position logic: Rotate around center.
                rotation: index * (360 / 32)
                antialiasing: true
                
                // Smooth height changes
                Behavior on height { NumberAnimation { duration: 80 } }
            }
        }

        Rectangle {
            id: container
            width: 200
            height: 200
            anchors.centerIn: parent
            radius: 100
            color: "#111"
            border.color: theme.purple
            border.width: 2
            z: 2 // Above visualizer
            
            // Spinning Animation if playing
            RotationAnimation on rotation {
                from: 0; to: 360; duration: 8000; loops: Animation.Infinite
                running: MprisService.isPlaying
            }
            
            // Vinyl / Album Art
            Image {
                id: albumArt
                anchors.fill: parent
                source: MprisService.artUrl
                fillMode: Image.PreserveAspectCrop
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: albumArt.width
                        height: albumArt.height
                        radius: width / 2
                    }
                }
                
                // Fallback Icon if no art
                Rectangle {
                    anchors.fill: parent
                    color: theme.surface
                    visible: albumArt.status !== Image.Ready
                    radius: width / 2
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰝚"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 32
                        color: theme.purple
                    }
                }
            }
        }
    }
    
    // --- Info ---
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        
        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            text: MprisService.title
            font.bold: true
            font.pixelSize: 16
            color: theme.fg
            elide: Text.ElideRight
        }
        
        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            text: MprisService.artist || "Unknown Artist"
            font.pixelSize: 12
            color: theme.subtext
            elide: Text.ElideRight
        }
    }
    
    // --- Controls ---
    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 20
        Layout.topMargin: 10
        
        // Prev
        Rectangle {
            width: 40; height: 40; radius: 20
            color: prevHover.containsMouse ? theme.surface : "transparent"
            border.color: theme.border; border.width: 1
            
            Text { anchors.centerIn: parent; text: "󰒮"; font.family: "Symbols Nerd Font"; color: theme.fg; font.pixelSize: 16 }
            MouseArea { id: prevHover; anchors.fill: parent; hoverEnabled: true; onClicked: MprisService.previous(); cursorShape: Qt.PointingHandCursor }
        }
        
        // Play/Pause
        Rectangle {
            width: 56; height: 56; radius: 28
            color: theme.purple
            
            Text { 
                anchors.centerIn: parent
                text: MprisService.isPlaying ? "󰏤" : "󰐊"
                font.family: "Symbols Nerd Font"
                color: theme.bg
                font.pixelSize: 24 
            }
            MouseArea { anchors.fill: parent; onClicked: MprisService.playPause(); cursorShape: Qt.PointingHandCursor }
        }
        
        // Next
        Rectangle {
            width: 40; height: 40; radius: 20
            color: nextHover.containsMouse ? theme.surface : "transparent"
            border.color: theme.border; border.width: 1
            
            Text { anchors.centerIn: parent; text: "󰒭"; font.family: "Symbols Nerd Font"; color: theme.fg; font.pixelSize: 16 }
            MouseArea { id: nextHover; anchors.fill: parent; hoverEnabled: true; onClicked: MprisService.next(); cursorShape: Qt.PointingHandCursor }
        }
    }
}
