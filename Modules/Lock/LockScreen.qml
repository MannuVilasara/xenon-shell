import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Core
import qs.Services

WlSessionLockSurface {
    id: root

    required property var lock
    required property var pam
    required property var colors

    color: "black"

    ScreencopyView {
        id: bg

        anchors.fill: parent
        captureSource: root.screen
        opacity: 0
        Component.onCompleted: opacity = 1
        layer.enabled: true

        Behavior on opacity {
            NumberAnimation {
                duration: 600
                easing.type: Easing.OutQuad
            }

        }

        layer.effect: FastBlur {
            radius: 64
            transparentBorder: true
        }

    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.4
    }

    RowLayout {
        id: bentoGrid

        anchors.centerIn: parent
        spacing: 24
        height: Math.min(parent.height - 100, 500)
        scale: 0.5
        opacity: 0

        ParallelAnimation {
            running: true

            NumberAnimation {
                target: bentoGrid
                property: "scale"
                to: 1
                duration: 500
                easing.type: Easing.OutBack
                easing.overshoot: 1
            }

            NumberAnimation {
                target: bentoGrid
                property: "opacity"
                to: 1
                duration: 500
                easing.type: Easing.OutCubic
            }

        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.preferredWidth: 280
            spacing: 24

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 180
                color: root.colors.surface
                radius: 28
                border.width: 1
                border.color: root.colors.border

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "System"
                        color: root.colors.fg
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: root.colors.border
                        Layout.margins: 10
                    }

                    RowLayout {
                        spacing: 15
                        Layout.alignment: Qt.AlignHCenter

                        ColumnLayout {
                            Text {
                                text: "CPU"
                                color: root.colors.muted
                                font.pixelSize: 12
                            }

                            Text {
                                text: Math.round(root.context.cpu.usage * 100) + "%"
                                color: root.colors.accent
                                font.pixelSize: 20
                                font.bold: true
                            }

                        }

                        ColumnLayout {
                            Text {
                                text: "RAM"
                                color: root.colors.muted
                                font.pixelSize: 12
                            }

                            Text {
                                text: Math.round(root.context.mem.usedPercentage * 100) + "%"
                                color: root.colors.accent
                                font.pixelSize: 20
                                font.bold: true
                            }

                        }

                    }

                }

            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: root.colors.surface
                radius: 28
                border.width: 1
                border.color: root.colors.border
                clip: true

                Image {
                    anchors.fill: parent
                    source: MprisService.artUrl
                    fillMode: Image.PreserveAspectCrop
                    visible: MprisService.artUrl !== ""
                    opacity: 0.3
                    layer.enabled: true

                    layer.effect: FastBlur {
                        radius: 32
                    }

                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12
                    width: parent.width - 24

                    Item {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 64
                        Layout.preferredHeight: 64

                        Image {
                            anchors.fill: parent
                            source: MprisService.artUrl
                            fillMode: Image.PreserveAspectCrop
                            visible: MprisService.artUrl !== ""
                            layer.enabled: true

                            layer.effect: OpacityMask {

                                maskSource: Rectangle {
                                    width: 64
                                    height: 64
                                    radius: 12
                                }

                            }

                        }

                        Text {
                            anchors.centerIn: parent
                            text: ""
                            font.family: "Nerd Font"
                            font.pixelSize: 32
                            color: root.colors.muted
                            visible: MprisService.artUrl === ""
                        }

                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: MprisService.title !== "" ? MprisService.title : "No Media"
                            color: root.colors.fg
                            font.pixelSize: 14
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }

                        Text {
                            text: MprisService.artist
                            color: root.colors.muted
                            font.pixelSize: 12
                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            visible: MprisService.artist !== ""
                        }

                    }

                    RowLayout {
                        spacing: 20
                        Layout.alignment: Qt.AlignHCenter
                        visible: MprisService.title !== "No Media"

                        Text {
                            text: ""
                            font.family: "Nerd Font"
                            color: root.colors.fg
                            font.pixelSize: 20

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -10
                                onClicked: MprisService.previous()
                                cursorShape: Qt.PointingHandCursor
                            }

                        }

                        Text {
                            text: MprisService.isPlaying ? "" : ""
                            font.family: "Nerd Font"
                            color: root.colors.accent
                            font.pixelSize: 32

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -10
                                onClicked: MprisService.playPause()
                                cursorShape: Qt.PointingHandCursor
                            }

                        }

                        Text {
                            text: ""
                            font.family: "Nerd Font"
                            color: root.colors.fg
                            font.pixelSize: 20

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -10
                                onClicked: MprisService.next()
                                cursorShape: Qt.PointingHandCursor
                            }

                        }

                    }

                }

            }

        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.preferredWidth: 320
            spacing: 24

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: root.colors.surface
                radius: 28
                border.width: 1
                border.color: root.colors.border

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0

                    Text {
                        text: Qt.formatTime(new Date(), "hh")
                        font.pixelSize: 100
                        font.weight: Font.Bold
                        color: root.colors.accent
                        Layout.alignment: Qt.AlignHCenter
                        lineHeight: 0.8

                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: parent.text = Qt.formatTime(new Date(), "hh")
                        }

                    }

                    Text {
                        text: Qt.formatTime(new Date(), "mm")
                        font.pixelSize: 100
                        font.weight: Font.Bold
                        color: root.colors.fg
                        Layout.alignment: Qt.AlignHCenter
                        lineHeight: 0.8

                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: parent.text = Qt.formatTime(new Date(), "mm")
                        }

                    }

                    Text {
                        text: Qt.formatDate(new Date(), "dddd, MMM d")
                        font.pixelSize: 16
                        color: root.colors.muted
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 20
                    }

                }

            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                color: root.colors.surface
                radius: 28
                border.width: 1
                border.color: inputField.activeFocus ? root.colors.accent : root.colors.border

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12
                    width: parent.width - 40

                    RowLayout {
                        spacing: 12
                        Layout.alignment: Qt.AlignHCenter

                        Image {
                            id: avatar

                            Layout.preferredWidth: 64
                            Layout.preferredHeight: 64
                            source: "file://" + Quickshell.env("HOME") + "/.face"
                            fillMode: Image.PreserveAspectCrop
                            layer.enabled: true

                            layer.effect: OpacityMask {

                                maskSource: Rectangle {
                                    width: avatar.width
                                    height: avatar.height
                                    radius: avatar.width / 2
                                }

                            }

                        }

                        Text {
                            text: "Session Locked"
                            color: root.colors.fg
                            font.pixelSize: 14
                            font.bold: true
                        }

                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        radius: 22
                        color: Qt.rgba(0, 0, 0, 0.5)

                        TextInput {
                            id: inputField

                            property int shakeOffset: 0

                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20
                            verticalAlignment: TextInput.AlignVCenter
                            color: "white"
                            font.pixelSize: 14
                            echoMode: TextInput.Password
                            passwordCharacter: "•"
                            focus: true
                            Component.onCompleted: forceActiveFocus()
                            onAccepted: {
                                if (text.length > 0) {
                                    root.pam.submit(text);
                                    text = "";
                                }
                            }
                            x: anchors.leftMargin + shakeOffset

                            SequentialAnimation {
                                id: shakeAnim

                                loops: 2

                                PropertyAnimation {
                                    target: inputField
                                    property: "shakeOffset"
                                    to: 10
                                    duration: 50
                                }

                                PropertyAnimation {
                                    target: inputField
                                    property: "shakeOffset"
                                    to: -10
                                    duration: 50
                                }

                                PropertyAnimation {
                                    target: inputField
                                    property: "shakeOffset"
                                    to: 0
                                    duration: 50
                                }

                            }

                            Connections {
                                function onFailure() {
                                    shakeAnim.start();
                                    inputField.color = root.colors.urgent;
                                    failTimer.start();
                                }

                                function onError() {
                                    shakeAnim.start();
                                    inputField.color = root.colors.urgent;
                                    failTimer.start();
                                }

                                target: root.pam
                            }

                            Timer {
                                id: failTimer

                                interval: 1000
                                onTriggered: inputField.color = root.colors.fg
                            }

                        }

                    }

                }

            }

        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 280
            color: root.colors.surface
            radius: 28
            border.width: 1
            border.color: root.colors.border

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 15

                Text {
                    text: "No Notifications"
                    color: root.colors.muted
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignHCenter
                }

            }

        }

    }

}
