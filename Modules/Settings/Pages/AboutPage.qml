import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Services as LocalServices

ColumnLayout {
    id: root

    property var context
    property var colors: context.colors
    property string kernelVersion: "..."
    property string distroName: distroInfo.name
    property string distroUrl: distroInfo.url
    property string distroIcon: distroInfo.icon
    property string distroBugUrl: distroInfo.bugUrl !== "" ? distroInfo.bugUrl : distroInfo.url
    property string distroSupportUrl: distroInfo.supportUrl !== "" ? distroInfo.supportUrl : distroInfo.url

    width: parent.width
    spacing: 16

    LocalServices.DistroInfoService {
        id: distroInfo
    }

    Process {
        id: kernelProc

        command: ["uname", "-r"]
        running: true

        stdout: SplitParser {
            onRead: (d) => {
                return kernelVersion = d.trim();
            }
        }

    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 180
        color: colors.surface
        radius: 20
        border.width: 1
        border.color: Qt.rgba(colors.border.r, colors.border.g, colors.border.b, 0.3)

        Rectangle {
            anchors.fill: parent
            radius: 20

            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: Qt.rgba(colors.accent.r, colors.accent.g, colors.accent.b, 0.08)
                }

                GradientStop {
                    position: 1
                    color: "transparent"
                }

            }

        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 44

            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 100
                Layout.leftMargin: 20
                Layout.alignment: Qt.AlignVCenter
                radius: 50
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    text: root.distroIcon
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 64
                    color: colors.accent
                }

            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 8

                Text {
                    text: root.distroName
                    font.pixelSize: 28
                    font.weight: Font.Bold
                    color: colors.fg
                }

                Text {
                    text: "Kernel: " + root.kernelVersion
                    font.pixelSize: 14
                    color: Qt.rgba(colors.fg.r, colors.fg.g, colors.fg.b, 0.6)
                    font.weight: Font.Medium
                    font.family: "JetBrainsMono Nerd Font"
                    opacity: 1
                }

                Item {
                    Layout.preferredHeight: 4
                }

                RowLayout {
                    spacing: 8

                    ActionPill {
                        icon: ""
                        label: "Website"
                        url: root.distroUrl
                    }

                    ActionPill {
                        icon: ""
                        label: "Support"
                        url: root.distroSupportUrl
                    }

                    ActionPill {
                        icon: ""
                        label: "Issues"
                        url: root.distroBugUrl
                    }

                }

            }

        }

    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 180
        color: colors.surface
        radius: 20
        border.width: 1
        border.color: Qt.rgba(colors.border.r, colors.border.g, colors.border.b, 0.3)

        RowLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 44

            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 100
                Layout.leftMargin: 20
                Layout.alignment: Qt.AlignVCenter
                radius: 50
                color: "transparent"

                Image {
                    anchors.centerIn: parent
                    source: "../../../Assets/logo.svg"
                    sourceSize: Qt.size(64, 64)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 6

                Text {
                    text: "Shell Configuration"
                    font.pixelSize: 28
                    font.weight: Font.Bold
                    color: colors.fg
                }

                Text {
                    text: "Custom Quickshell config by Mannu"
                    font.pixelSize: 14
                    color: Qt.rgba(colors.fg.r, colors.fg.g, colors.fg.b, 0.6)
                }

                Item {
                    Layout.preferredHeight: 4
                }

                RowLayout {
                    spacing: 8

                    ActionPill {
                        icon: ""
                        label: "Repository"
                        url: "https://github.com/MannuVilasara/shell"
                    }

                    ActionPill {
                        icon: ""
                        label: "Issues"
                        url: "https://github.com/MannuVilasara/shell/issues"
                    }

                    ActionPill {
                        icon: ""
                        label: "Support"
                        url: "https://discord.com/users/786926252811485186"
                    }

                }

            }

        }

    }

    RowLayout {
        Layout.topMargin: 16
        spacing: 12

        Rectangle {
            width: 4
            height: 24
            radius: 2
            color: colors.accent
        }

        Text {
            text: "Core Developers"
            font.pixelSize: 18
            font.weight: Font.Bold
            color: colors.fg
        }

    }

    GridLayout {
        Layout.fillWidth: true
        columns: root.width > 600 ? 2 : 1
        columnSpacing: 16
        rowSpacing: 16

        Repeater {
            model: [{
                "name": "MannuVilasara",
                "url": "https://github.com/mannuvilasara",
                "image": "/etc/xdg/quickshell/mannu/Assets/mannu.png"
            }, {
                "name": "ikeshav26",
                "url": "https://github.com/ikeshav26",
                "image": "/etc/xdg/quickshell/mannu/Assets/keshav.png"
            }]

            delegate: Rectangle {
                id: devCard

                Layout.fillWidth: true
                Layout.preferredHeight: 90
                radius: 16
                color: colors.surface
                border.width: 1
                border.color: hoverHandler.hovered ? colors.accent : Qt.rgba(colors.border.r, colors.border.g, colors.border.b, 0.4)

                HoverHandler {
                    id: hoverHandler

                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: Qt.openUrlExternally(modelData.url)
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Item {
                        Layout.preferredWidth: 58
                        Layout.preferredHeight: 58

                        Image {
                            id: avatar

                            anchors.fill: parent
                            source: "file://" + modelData.image
                            sourceSize: Qt.size(58, 58)
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            visible: false
                            onStatusChanged: {
                                if (status === Image.Error)
                                    fallback.visible = true;

                            }
                        }

                        OpacityMask {
                            anchors.fill: parent
                            source: avatar
                            visible: avatar.status === Image.Ready

                            maskSource: Rectangle {
                                width: 58
                                height: 58
                                radius: 29
                                visible: true
                            }

                        }

                        Rectangle {
                            id: fallback

                            anchors.fill: parent
                            radius: 29
                            color: Qt.rgba(colors.accent.r, colors.accent.g, colors.accent.b, 0.2)
                            visible: avatar.status !== Image.Ready

                            Text {
                                anchors.centerIn: parent
                                text: modelData.name.charAt(0)
                                font.bold: true
                                font.pixelSize: 24
                                color: colors.accent
                            }

                        }

                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: modelData.name
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            color: colors.fg
                        }

                    }

                    Text {
                        text: ""
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: hoverHandler.hovered ? colors.accent : colors.muted

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }

                        }

                    }

                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 200
                    }

                }

            }

        }

    }

    Item {
        Layout.fillHeight: true
    }

    component ActionPill: Rectangle {
        id: pill

        property string icon
        property string label
        property string url

        implicitWidth: pillRow.implicitWidth + 20
        implicitHeight: 28
        radius: 14
        color: pillHover.containsMouse ? colors.accent : "transparent"
        border.width: 1
        border.color: pillHover.containsMouse ? colors.accent : Qt.rgba(colors.border.r, colors.border.g, colors.border.b, 0.5)

        MouseArea {
            id: pillHover

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Qt.openUrlExternally(pill.url)
        }

        RowLayout {
            id: pillRow

            anchors.centerIn: parent
            spacing: 6

            Text {
                text: pill.icon
                font.family: "Symbols Nerd Font"
                color: pillHover.containsMouse ? colors.bg : Qt.rgba(colors.fg.r, colors.fg.g, colors.fg.b, 0.6)
                font.pixelSize: 12
            }

            Text {
                text: pill.label
                font.weight: Font.Medium
                color: pillHover.containsMouse ? colors.bg : Qt.rgba(colors.fg.r, colors.fg.g, colors.fg.b, 0.6)
                font.pixelSize: 11
            }

        }

        Behavior on color {
            ColorAnimation {
                duration: 150
            }

        }

    }

}
