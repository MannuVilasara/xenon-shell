import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Core
import "../../../../Services" // Ensure this path points to where CpuService.qml is located

ColumnLayout {
    id: root

    required property var theme

    spacing: 12

    // --- Services Instantiation ---
    // We create an instance here because CpuService is not a Singleton
    CpuService {
        id: cpuService
    }

    // Header
    Text {
        text: "System Resources"
        font.bold: true
        font.pixelSize: 14
        color: theme.fg
        Layout.leftMargin: 4
        opacity: 0.9
    }

    // --- Resources List ---
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 10

        // 1. CPU Resource
        ResourceItem {
            label: "CPU"
            icon: "󰻠"
            iconColor: theme.urgent
            // Bind directly to the service instance
            valueText: cpuService.usage + "%"
            progress: cpuService.usage / 100
        }

        // 2. RAM Resource
        // Assuming MemService is still available globally or via qs.Services.
        // If MemService is also not a singleton, you need to instantiate it like CpuService above.
        ResourceItem {
            label: "RAM"
            icon: "󰍛"
            iconColor: theme.accent
            // Safety check in case MemService is missing/loading
            valueText: (typeof MemService !== "undefined" ? 
                       (Math.round(MemService.used / 1024 / 1024 / 1024 * 10) / 10) : 0) + " GB"
            progress: (typeof MemService !== "undefined" ? 
                      (MemService.used / MemService.total) : 0)
        }

        // 3. SSD Resource (Mock data for now)
        ResourceItem {
            label: "SSD"
            icon: "󰋊"
            iconColor: theme.green
            valueText: "24%"
            progress: 0.24
        }
    }

    // --- Reusable Component ---
    component ResourceItem: Rectangle {
        property string label
        property string icon
        property color iconColor
        property string valueText
        property real progress: 0

        Layout.fillWidth: true
        Layout.preferredHeight: 64
        radius: 12
        color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.4)
        border.color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.08)
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 14

            // Icon
            Text {
                text: icon
                font.family: "Symbols Nerd Font"
                font.pixelSize: 22
                color: iconColor
            }

            // Info & Bar
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                Layout.alignment: Qt.AlignVCenter

                // Header Row
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: label
                        font.pixelSize: 12
                        font.bold: true
                        color: theme.fg
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: valueText
                        font.pixelSize: 12
                        color: theme.fg
                        font.family: "JetBrains Mono" // Monospace for numbers
                    }
                }

                // Progress Bar Background
                Rectangle {
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.1)

                    // Active Progress
                    Rectangle {
                        height: parent.height
                        radius: parent.radius
                        color: iconColor
                        width: parent.width * progress

                        // Smooth animation when values change
                        Behavior on width {
                            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                        }
                    }
                }
            }
        }
    }
}