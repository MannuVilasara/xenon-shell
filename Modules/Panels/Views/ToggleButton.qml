import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string label: ""
    property string sublabel: ""
    property string icon: ""
    property bool active: false
    property bool showChevron: false
    required property var theme

    radius: 14
    color: active ? theme.accent : theme.surface
    border.width: 1
    border.color: active ? theme.accentActive : theme.border

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        Text {
            text: root.icon
            font.family: "Symbols Nerd Font"
            font.pixelSize: 20
            color: root.active ? theme.bg : theme.text
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.label
                font.bold: true
                font.pixelSize: 13
                color: root.active ? theme.bg : theme.text
            }

            Text {
                text: root.sublabel
                font.pixelSize: 11
                color: root.active ? theme.bg : theme.muted
                opacity: root.active ? 0.9 : 1
                visible: text !== ""
            }

        }

        Text {
            visible: root.showChevron
            text: "󰅂"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 14
            color: root.active ? theme.bg : theme.muted
        }

    }

    Behavior on color {
        ColorAnimation {
            duration: 150
        }

    }

}
