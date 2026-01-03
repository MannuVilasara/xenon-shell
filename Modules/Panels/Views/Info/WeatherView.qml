import QtQuick
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
    implicitHeight: 300 // 180 (Visual) + 120 (Forecast) + 0 spacing

    // Muted Color definitions
    readonly property color dayTop: "#A0C4FF"      // Muted Blue
    readonly property color dayMid: "#BDE0FE"
    readonly property color dayBot: "#E2F0CB"      // Slight Greenish tint for ground/horizon

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
            spacing: 0

            // 1. TOP SECTION: Visuals
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 180 // Reduced height (was ~220+)
                radius: 20
                clip: true
                color: "transparent"

                // Dynamic Gradient Background
                Rectangle {
                    anchors.fill: parent
                    radius: 20
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: root.topColor }
                        GradientStop { position: 0.5; color: root.midColor }
                        GradientStop { position: 1.0; color: root.botColor }
                    }
                }
                
                // Darkening Overlay (simulating 'atmosphere')
                Rectangle {
                    anchors.fill: parent
                    radius: 20
                    color: "black"
                    opacity: root.blend.night * 0.4
                }

                // Celestial Body (Sun/Moon)
                Item {
                    id: celestialContainer
                    anchors.fill: parent
                    
                    // Arc path calculation
                    property real arcWidth: width - 60
                    property real arcHeight: height * 0.5 // Higher arch relative to short height
                    property real cx: width / 2
                    property real cy: height * 0.9 // Pushed down slightly
                    
                    // Draw the white arc line
                    Shape {
                        anchors.fill: parent
                        ShapePath {
                            strokeWidth: 2
                            strokeColor: Qt.rgba(1,1,1,0.3)
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap
                            startX: celestialContainer.cx - celestialContainer.arcWidth/2
                            startY: celestialContainer.cy
                            PathArc {
                                x: celestialContainer.cx + celestialContainer.arcWidth/2
                                y: celestialContainer.cy
                                radiusX: celestialContainer.arcWidth/2
                                radiusY: celestialContainer.arcHeight
                                useLargeArc: false
                            }
                        }
                    }

                    Rectangle {
                        id: celestialBody
                        width: 32; height: 32
                        radius: 16
                        
                        property real progress: WeatherService.effectiveSunProgress
                        property real angle: Math.PI * (1 - progress)
                        
                        x: celestialContainer.cx + (celestialContainer.arcWidth / 2) * Math.cos(angle) - width / 2
                        y: celestialContainer.cy - celestialContainer.arcHeight * Math.sin(angle) - height / 2

                        Behavior on x { NumberAnimation { duration: 1000 } }
                        Behavior on y { NumberAnimation { duration: 1000 } }

                        gradient: Gradient {
                            GradientStop { position: 0.0; color: WeatherService.effectiveIsDay ? "#FFE082" : "#F5F5F5" }
                            GradientStop { position: 1.0; color: WeatherService.effectiveIsDay ? "#FFB74D" : "#BDBDBD" }
                        }
                        
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: WeatherService.effectiveIsDay ? "#FFD54F" : "#ffffff"
                            shadowBlur: 0.8
                            shadowOpacity: 0.6
                        }
                    }
                }

                // Weather Effects (Clouds, etc.)
                Item {
                    id: cloudEffect
                    anchors.fill: parent
                    visible: true 
                    // Boosted opacity: default 0.4 for clear/decorative, higher for actual clouds
                    opacity: WeatherService.effectiveWeatherEffect === "clear" ? 0.4 : Math.max(0.6, WeatherService.effectiveWeatherIntensity)

                    Repeater {
                        model: 5
                        Item {
                            property real speed: 0.3 + Math.random() * 0.4
                            x: -200
                            y: parent.height * 0.3 + (index * 20)
                            width: 150 + index * 30
                            height: 60
                            z: index // layering
                            
                            Rectangle {
                                anchors.fill: parent
                                radius: height/2
                                color: Qt.rgba(1, 1, 1, 0.2 + (index * 0.05))
                            }

                            NumberAnimation on x {
                                from: -300
                                to: root.width + 100
                                duration: 25000 / parent.speed
                                loops: Animation.Infinite
                                running: cloudEffect.visible
                            }
                        }
                    }
                }
                
                // Rain/Snow (Overlaying everything)
                Item {
                    id: precipEffect
                    anchors.fill: parent
                    clip: true
                    visible: ["rain", "drizzle", "snow", "thunderstorm"].includes(WeatherService.effectiveWeatherEffect)

                    Repeater {
                        model: 30
                        Rectangle {
                            x: Math.random() * parent.width
                            y: -20
                            width: WeatherService.effectiveWeatherEffect === "snow" ? 3 : 1
                            height: WeatherService.effectiveWeatherEffect === "snow" ? 3 : 15
                            radius: width/2
                            color: "white"
                            opacity: 0.6
                            rotation: 10

                            NumberAnimation on y {
                                from: -20
                                to: root.height + 20
                                duration: 800 + Math.random() * 800
                                loops: Animation.Infinite
                                running: precipEffect.visible
                            }
                        }
                    }
                }

                // INFO OVERLAY (Temp & Desc)
                Item {
                    anchors.fill: parent
                    anchors.margins: 20

                    // Top Left: Temp
                    Text {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        text: WeatherService.temperature
                        font.pixelSize: 42
                        font.bold: true
                        color: "white"
                        style: Text.Outline; styleColor: "#40000000"
                    }

                    // Top Right: Condition
                    Text {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: 8
                        text: WeatherService.effectiveWeatherDescription
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        font.capitalization: Font.Capitalize
                        color: "white"
                        opacity: 0.9
                        style: Text.Outline; styleColor: "#40000000"
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
