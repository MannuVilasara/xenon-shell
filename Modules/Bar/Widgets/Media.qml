import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Services
import qs.Widgets

Rectangle {
    id: root

    required property var colors
    required property string fontFamily
    required property int fontSize
    required property var globalState
    readonly property bool isPlaying: MprisService.isPlaying
    readonly property bool hasMedia: MprisService.title !== ""

    Layout.preferredHeight: 30
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: layout.implicitWidth + 8
    radius: height / 2
    color: "transparent"

    HoverHandler {
        id: hoverHandler
    }

    TapHandler {
        onTapped: root.globalState.requestInfoPanelTab(1)
    }

    RowLayout {
        id: layout

        anchors.centerIn: parent
        spacing: 0
        width: parent.width

        // Spacing animation
        Item {
            Layout.preferredWidth: hoverHandler.hovered ? 8 : 4

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }

            }

        }

        // Text Container
        Item {
            id: textContainer

            Layout.preferredWidth: hoverHandler.hovered ? Math.min(textMetrics.width, 200) : 0
            Layout.preferredHeight: root.height
            clip: true

            Text {
                id: mediaText

                anchors.verticalCenter: parent.verticalCenter
                text: {
                    if (MprisService.playerCount === 0 || MprisService.title === "No Media")
                        return "No Media Playing";

                    let t = MprisService.title;
                    let a = MprisService.artist;
                    if (a !== "" && a !== "Unknown Artist")
                        return t + " • " + a;

                    return t;
                }
                color: root.colors.fg
                font.pixelSize: root.fontSize
                font.family: root.fontFamily
                font.bold: true
                elide: Text.ElideRight
                width: parent.width
            }

            TextMetrics {
                id: textMetrics

                font: mediaText.font
                text: mediaText.text
            }

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }

            }

        }

        // Spacing
        Item {
            Layout.preferredWidth: hoverHandler.hovered ? 8 : 0

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }

            }

        }

        // Icon / Art Container
        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: 12
            color: root.isPlaying ? Qt.rgba(root.colors.green.r, root.colors.green.g, root.colors.green.b, 0.2) : Qt.rgba(root.colors.muted.r, root.colors.muted.g, root.colors.muted.b, 0.2)

            Icon {
                anchors.centerIn: parent
                icon: Icons.music
                color: root.colors.fg
                font.pixelSize: root.fontSize
                visible: MprisService.artUrl === ""
            }

            Image {
                anchors.fill: parent
                anchors.margins: 2
                source: MprisService.artUrl
                visible: MprisService.artUrl !== ""
                fillMode: Image.PreserveAspectCrop
                layer.enabled: true

                layer.effect: OpacityMask {

                    maskSource: Rectangle {
                        width: 20
                        height: 20
                        radius: 10
                    }

                }

            }

            // Rotating animation for playing state
            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: 4000
                loops: Animation.Infinite
                running: root.isPlaying && MprisService.artUrl !== ""
            }

        }

    }

}
