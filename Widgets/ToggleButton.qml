import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    property string label: ""
    property string sublabel: ""
    property string icon: ""
    property bool active: false
    property bool showChevron: false
    property var theme

    implicitHeight: theme ? theme.toggleHeight : 88
    radius: 16
    color: active ? (theme ? theme.tileActive : "#CBA6F7") : (theme ? theme.tile : "#2F333D")
    border.width: 1
    border.color: active ? (theme ? theme.tileActive : "#CBA6F7") : (theme ? theme.border : "#2F333D")
    scale: toggleMouse.containsMouse ? 1.02 : 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 14

        Text {
            text: icon
            font.pixelSize: theme ? theme.toggleIconSize : 24
            font.family: "Symbols Nerd Font"
            color: active ? (theme ? theme.bg : "#1A1D26") : (theme ? theme.secondary : "#9BA3B8")

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }

            }

        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: label
                font.pixelSize: 14
                font.weight: Font.Medium
                color: active ? (theme ? theme.bg : "#1A1D26") : (theme ? theme.text : "#E8EAF0")
                elide: Text.ElideRight
                Layout.fillWidth: true

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }

                }

            }

            Text {
                text: sublabel
                font.pixelSize: 12
                color: active ? (theme ? Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.7) : Qt.rgba(0.1, 0.11, 0.15, 0.7)) : (theme ? theme.secondary : "#9BA3B8")
                elide: Text.ElideRight
                Layout.fillWidth: true
                visible: sublabel !== ""

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }

                }

            }

        }

        Text {
            text: "󰅂"
            font.pixelSize: 16
            font.family: "Symbols Nerd Font"
            color: active ? (theme ? theme.bg : "#1A1D26") : (theme ? theme.iconMuted : "#70727C")
            visible: showChevron

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }

            }

        }

    }

    MouseArea {
        id: toggleMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: active = !active
    }

    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }

    }

    Behavior on border.color {
        ColorAnimation {
            duration: 200
        }

    }

    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutQuad
        }

    }

}
