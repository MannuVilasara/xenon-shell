import "../../../../Services" as Services
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Core
import qs.Services

ColumnLayout {
    id: root

    required property var theme

    spacing: 16

    Item {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 240 // Increased for visualizer space
        Layout.preferredHeight: 240

        Connections {
            function onValuesChanged() {
                visualizerRepeater.requestPaint();
            }

            target: Services.CavaService
        }

        Binding {
            target: Services.CavaService
            property: "running"
            value: MprisService.isPlaying && root.visible
        }

        Repeater {
            id: visualizerRepeater

            model: 32 // Matches CavaService barsCount

            Rectangle {
                id: bar

                property var val: Services.CavaService.values[index] || 0

                anchors.centerIn: parent
                width: 6
                height: 200 + (val * 150)
                color: theme.accent
                opacity: 0.8 // Increased opacity
                radius: 3
                rotation: index * (360 / 32)
                antialiasing: true

                Behavior on height {
                    NumberAnimation {
                        duration: 80
                    }

                }

            }

        }

        Rectangle {
            id: container

            width: 200
            height: 200
            anchors.centerIn: parent
            radius: 100
            color: "#111"
            border.color: theme.accent
            border.width: 2
            z: 2 // Above visualizer

            Image {
                id: albumArt

                anchors.fill: parent
                source: MprisService.artUrl
                fillMode: Image.PreserveAspectCrop
                layer.enabled: true

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
                        color: theme.accent
                    }

                }

                layer.effect: OpacityMask {

                    maskSource: Rectangle {
                        width: albumArt.width
                        height: albumArt.height
                        radius: width / 2
                    }

                }

            }

            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: 8000
                loops: Animation.Infinite
                running: MprisService.isPlaying
            }

        }

    }

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

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 20
        Layout.topMargin: 10

        Rectangle {
            width: 40
            height: 40
            radius: 20
            color: prevHover.containsMouse ? theme.surface : "transparent"
            border.color: theme.border
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "󰒮"
                font.family: "Symbols Nerd Font"
                color: theme.fg
                font.pixelSize: 16
            }

            MouseArea {
                id: prevHover

                anchors.fill: parent
                hoverEnabled: true
                onClicked: MprisService.previous()
                cursorShape: Qt.PointingHandCursor
            }

        }

        Rectangle {
            width: 56
            height: 56
            radius: 28
            color: theme.accent

            Text {
                anchors.centerIn: parent
                text: MprisService.isPlaying ? "󰏤" : "󰐊"
                font.family: "Symbols Nerd Font"
                color: theme.bg
                font.pixelSize: 24
            }

            MouseArea {
                anchors.fill: parent
                onClicked: MprisService.playPause()
                cursorShape: Qt.PointingHandCursor
            }

        }

        Rectangle {
            width: 40
            height: 40
            radius: 20
            color: nextHover.containsMouse ? theme.surface : "transparent"
            border.color: theme.border
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "󰒭"
                font.family: "Symbols Nerd Font"
                color: theme.fg
                font.pixelSize: 16
            }

            MouseArea {
                id: nextHover

                anchors.fill: parent
                hoverEnabled: true
                onClicked: MprisService.next()
                cursorShape: Qt.PointingHandCursor
            }

        }

    }

}
