import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Core

Item {
    id: root

    required property var theme
    required property var sysInfo

    implicitWidth: 460
    implicitHeight: 280

    RowLayout {
        anchors.centerIn: parent
        spacing: 30

        Item {
            Layout.preferredWidth: 140
            Layout.preferredHeight: 140

            Text {
                id: logoIcon

                anchors.centerIn: parent
                text: "󰣇"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 120
                color: theme.accent // Fallback
            }

        }

        ColumnLayout {
            spacing: 6

            Text {
                text: sysInfo.userName + "@" + sysInfo.hostName
                font.bold: true
                font.pixelSize: 20
                color: theme.blue
                font.family: "JetBrainsMono Nerd Font"
                Layout.bottomMargin: 8
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 2
                color: theme.subtext
                opacity: 0.5
                Layout.bottomMargin: 8
            }

            Repeater {
                model: [{
                    "label": "OS",
                    "key": "osName",
                    "icon": "",
                    "color": theme.blue
                }, {
                    "label": "Host",
                    "key": "hostName",
                    "icon": "",
                    "color": theme.purple
                }, {
                    "label": "Kernel",
                    "key": "kernelVersion",
                    "icon": "",
                    "color": theme.green
                }, {
                    "label": "Uptime",
                    "key": "uptime",
                    "icon": "",
                    "color": theme.yellow
                }, {
                    "label": "Shell",
                    "key": "shellName",
                    "icon": "",
                    "color": theme.orange
                }, {
                    "label": "WM",
                    "key": "wmName",
                    "icon": "",
                    "color": theme.red
                }]

                RowLayout {
                    required property var modelData

                    spacing: 12

                    Text {
                        text: modelData.icon
                        color: modelData.color
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 14
                    }

                    Text {
                        text: modelData.label + ":"
                        color: modelData.color
                        font.bold: true
                        font.pixelSize: 14
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    Text {
                        text: root.sysInfo[modelData.key] // Dynamic lookup
                        color: theme.fg
                        font.pixelSize: 14
                        font.family: "JetBrainsMono Nerd Font"
                    }

                }

            }

            RowLayout {
                Layout.topMargin: 12
                spacing: 6

                Repeater {
                    model: [theme.red, theme.green, theme.yellow, theme.blue, theme.purple, theme.teal]

                    Rectangle {
                        required property color modelData

                        width: 24
                        height: 12
                        radius: 2
                        color: modelData
                    }

                }

            }

        }

    }

}
