import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Core
import qs.Services

ColumnLayout {
    id: root

    required property var theme

    spacing: 12

    Text {
        text: "System Resources"
        font.bold: true
        font.pixelSize: 14
        color: theme.fg
    }

    Repeater {
        // Mock Disk for now if DiskService isn't ready

        model: [{
            "label": "CPU",
            "val": Math.round(CpuService.usage) + "%",
            "progress": CpuService.usage / 100,
            "color": theme.urgent,
            "icon": "󰻠"
        }, {
            "label": "RAM",
            "val": Math.round(MemService.used / 1024 / 1024 / 1024 * 10) / 10 + " GB",
            "progress": MemService.used / MemService.total,
            "color": theme.accent,
            "icon": "󰍛"
        }, {
            "label": "SSD",
            "val": "24%",
            "progress": 0.24,
            "color": theme.green,
            "icon": "󰋊"
        }]

        Rectangle {
            required property var modelData

            Layout.fillWidth: true
            Layout.preferredHeight: 64
            radius: 12
            color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.4)
            border.color: theme.border
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                Text {
                    text: modelData.icon
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 20
                    color: modelData.color
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: modelData.label
                            font.pixelSize: 12
                            font.bold: true
                            color: theme.fg
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: modelData.val
                            font.pixelSize: 12
                            color: theme.fg
                        }

                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 4
                        radius: 2
                        color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.1)

                        Rectangle {
                            height: parent.height
                            radius: parent.radius
                            color: modelData.color
                            width: parent.width * modelData.progress

                            Behavior on width {
                                NumberAnimation {
                                    duration: 400
                                }

                            }

                        }

                    }

                }

            }

        }

    }

}
