import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string label: ""
    property string icon: ""
    property real value: 0
    required property var theme

    signal changeRequested(real newValue)

    Layout.fillWidth: true
    implicitHeight: 52
    radius: 12
    color: theme.surface
    border.width: 1
    border.color: theme.border

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        Text {
            text: root.icon
            font.family: "Symbols Nerd Font"
            font.pixelSize: 16
            color: theme.text
        }

        Text {
            Layout.preferredWidth: 70
            text: root.label
            font.pixelSize: 13
            color: theme.text
        }

        Slider {
            id: slider

            Layout.fillWidth: true
            from: 0
            to: 1
            onMoved: root.changeRequested(value)

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton // Passthrough clicks to slider
                onWheel: (wheel) => {
                    var step = 0.05;
                    var next = (wheel.angleDelta.y > 0) ? slider.value + step : slider.value - step;
                    next = Math.max(0, Math.min(1, next));
                    root.changeRequested(next);
                }
            }

            Binding on value {
                value: root.value
                when: !slider.pressed
                restoreMode: Binding.RestoreBinding
            }

            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 200
                implicitHeight: 4
                width: slider.availableWidth
                height: implicitHeight
                radius: 2
                color: Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.2)

                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    color: theme.accentActive
                    radius: 2
                }

            }

            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 16
                implicitHeight: 16
                radius: 8
                color: "#FFFFFF"
                border.width: 0
            }

        }

        Text {
            text: Math.round(slider.value * 100) + "%"
            font.pixelSize: 12
            color: theme.muted
            Layout.preferredWidth: 30
            horizontalAlignment: Text.AlignRight
        }

    }

}
