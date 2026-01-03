import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Effects
import qs.Core
import qs.Services

Item {
    id: root

    required property var theme

    implicitWidth: 440
    implicitHeight: 316 // 180 (Visual) + 120 (Forecast) + 16 spacing

    // Muted Color definitions
    readonly property color dayTop: "#89CFF0"      // Baby Blue
    readonly property color dayMid: "#A0E6FF"
    readonly property color dayBot: "#F9F871"      // Light Yellow-Green

    readonly property color eveningTop: "#23252F"
    readonly property color eveningMid: "#7A5C61"
    readonly property color eveningBot: "#F7B267"

    readonly property color nightTop: "#08090F"
    readonly property color nightMid: "#1B202E"
    readonly property color nightBot: "#2F3542"

    function blendColors(c1, c2, c3, blend) {
        var r = c1.r * blend.day + c2.r * blend.evening + c3.r * blend.night;
        var g = c1.g * blend.day + c2.g * blend.evening + c3.g * blend.night;
        var b = c1.b * blend.day + c2.b * blend.evening + c3.b * blend.night;
        return Qt.rgba(r, g, b, 1);
    }

    readonly property var blend: WeatherService.effectiveTimeBlend
    readonly property color topColor: blendColors(dayTop, eveningTop, nightTop, blend)
    readonly property color midColor: blendColors(dayMid, eveningMid, nightMid, blend)
    readonly property color botColor: blendColors(dayBot, eveningBot, nightBot, blend)

    Rectangle {
        id: cardBackground
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
            anchors.fill: parent
            spacing: 16

            // 1. TOP SECTION: Visuals (Split)
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 180
                spacing: 16

                // LEFT: Weather Visuals
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 20
                    clip: true
                    color: "transparent"

                    // Image Background
                    Image {
                        id: weatherBgImg
                        anchors.fill: parent
                        source: "../../../../Assets/" + (WeatherService.isDay ? "day.png" : "night.png")
                        fillMode: Image.PreserveAspectCrop
                        
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: maskRect
                        }

                        // Fallback Gradient
                        Rectangle {
                            anchors.fill: parent
                            visible: parent.status !== Image.Ready
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: root.topColor }
                                GradientStop { position: 0.5; color: root.midColor }
                                GradientStop { position: 1.0; color: root.botColor }
                            }
                        }
                    }
                    
                    Rectangle {
                        id: maskRect
                        anchors.fill: parent
                        radius: 20
                        visible: false
                    }
                    
                    // Dark Overlay
                    Rectangle {
                        anchors.fill: parent
                        radius: 20
                        color: "black"
                        opacity: root.blend.night * 0.4
                    }

                    // Temp (Top Left)
                    Text {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: 16
                        text: WeatherService.temperature
                        font.pixelSize: 36
                        font.bold: true
                        color: "white"
                        style: Text.Outline; styleColor: "#40000000"
                    }

                    // Centered Icon (Sun/Moon)
                    Text {
                        anchors.centerIn: parent
                        text: WeatherService.isDay ? "󰖙" : "󰖔"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 64
                        color: WeatherService.isDay ? "#FFCC4D" : "#F5F5F5"
                        style: Text.Outline; styleColor: "#40000000"
                        
                        // Subtle Glow
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: parent.color
                            shadowBlur: 1.0
                            shadowOpacity: 0.5
                        }
                    }

                    // Condition Text (Bottom Center)
                    Text {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.margins: 12
                        text: WeatherService.conditionText
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        font.capitalization: Font.Capitalize
                        color: "white"
                        opacity: 0.9
                        style: Text.Outline; styleColor: "#40000000"
                    }
                }

                // RIGHT: Binary Clock
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 20
                    color: "#1E1E1E"
                    border.width: 1
                    border.color: Qt.rgba(1,1,1,0.05)

                    property int hours: 0
                    property int minutes: 0
                    property int seconds: 0

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        triggeredOnStart: true
                        onTriggered: {
                            var now = new Date();
                            parent.hours = now.getHours();
                            parent.minutes = now.getMinutes();
                            parent.seconds = now.getSeconds();
                        }
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        // Hours
                        RowLayout {
                            spacing: 4
                            BinaryColumn { value: Math.floor(parent.parent.parent.hours / 10); bits: 2; activeColor: root.theme.urgent }
                            BinaryColumn { value: parent.parent.parent.hours % 10; bits: 4; activeColor: root.theme.urgent }
                        }

                        // Separator
                        Rectangle { width: 1; height: 60; color: Qt.rgba(1,1,1,0.1) }

                        // Minutes
                        RowLayout {
                            spacing: 4
                            BinaryColumn { value: Math.floor(parent.parent.parent.minutes / 10); bits: 3; activeColor: root.theme.accent }
                            BinaryColumn { value: parent.parent.parent.minutes % 10; bits: 4; activeColor: root.theme.accent }
                        }

                        // Separator
                        Rectangle { width: 1; height: 60; color: Qt.rgba(1,1,1,0.1) }

                        // Seconds
                        RowLayout {
                            spacing: 4
                            BinaryColumn { value: Math.floor(parent.parent.parent.seconds / 10); bits: 3; activeColor: root.theme.text }
                            BinaryColumn { value: parent.parent.parent.seconds % 10; bits: 4; activeColor: root.theme.text }
                        }
                    }
                }
            }
    
    component BinaryColumn : Column {
        id: binCol
        property int value: 0
        property int bits: 4
        property real dotSize: 12
        property color activeColor: "white"

        spacing: 4
        Layout.alignment: Qt.AlignBottom

        Repeater {
            model: binCol.bits
            Rectangle {
                property int bitIndex: (binCol.bits - 1) - index
                property bool isActive: (binCol.value >> bitIndex) & 1

                width: binCol.dotSize
                height: binCol.dotSize
                radius: binCol.dotSize / 2
                color: isActive ? binCol.activeColor : Qt.rgba(1,1,1,0.1)
                
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }
    }

            // 2. BOTTOM SECTION: Forecast (35% Height)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120 // Fixed height for forecast
                radius: 20
                color: "#1E1E1E" // Dark background
                border.width: 1
                border.color: Qt.rgba(1,1,1,0.05)

                ListView {
                    anchors.fill: parent
                    anchors.margins: 16
                    orientation: ListView.Horizontal
                    spacing: 0 // Spacing handled by item width/layout
                    clip: true
                    interactive: false // Fit to width
                    
                    model: WeatherService.forecastModel

                    delegate: Item {
                        width: ListView.view.width / 5
                        height: ListView.view.height
                        
                        // Vertical Divider (except for last item)
                        Rectangle {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 1
                            height: parent.height * 0.6
                            color: Qt.rgba(1,1,1,0.1)
                            visible: index < 4
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: index === 0 ? "Today" : modelData.day
                                color: Qt.rgba(1,1,1,0.9)
                                font.pixelSize: 13
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: modelData.icon
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 20
                                color: "#FFD54F" // Gold/Yellow icon
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Column {
                                spacing: 2
                                Layout.alignment: Qt.AlignHCenter
                                Text {
                                    text: modelData.max
                                    color: "white"
                                    font.bold: true
                                    font.pixelSize: 14
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: modelData.min
                                    color: "white"
                                    font.pixelSize: 12
                                    opacity: 0.5
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
