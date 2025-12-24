import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Core
import qs.Services

ColumnLayout {
    id: root

    required property var theme

    spacing: 16

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 110
        radius: 20
        border.color: Qt.rgba(theme.blue.r, theme.blue.g, theme.blue.b, 0.3)
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 20

            Text {
                text: WeatherService.icon
                font.family: "Symbols Nerd Font"
                font.pixelSize: 48
                color: theme.fg
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: WeatherService.temperature
                    color: theme.fg
                    font.bold: true
                    font.pixelSize: 28
                }

                Text {
                    text: WeatherService.condition
                    color: theme.subtext
                    font.pixelSize: 13
                }

            }

        }

        gradient: Gradient {
            GradientStop {
                position: 0
                color: Qt.rgba(theme.blue.r, theme.blue.g, theme.blue.b, 0.2)
            }

            GradientStop {
                position: 1
                color: Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.2)
            }

        }

    }

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: 10
        columnSpacing: 10

        Repeater {
            // Mock
            // Mock

            model: [{
                "icon": "󰖎",
                "label": "Humidity",
                "val": WeatherService.humidity
            }, {
                "icon": "󰖝",
                "label": "Wind",
                "val": WeatherService.wind
            }, {
                "icon": "󰖒",
                "label": "Pressure",
                "val": "1012 hPa"
            }, {
                "icon": "󰖕",
                "label": "UV Index",
                "val": "3"
            }]

            Rectangle {
                required property var modelData

                Layout.fillWidth: true
                Layout.preferredHeight: 60
                radius: 12
                color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.5)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Text {
                        text: modelData.icon
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: theme.accent
                    }

                    ColumnLayout {
                        spacing: 0

                        Text {
                            text: modelData.label
                            color: theme.subtext
                            font.pixelSize: 10
                        }

                        Text {
                            text: modelData.val
                            color: theme.fg
                            font.pixelSize: 12
                            font.bold: true
                        }

                    }

                }

            }

        }

    }

}
